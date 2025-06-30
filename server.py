import random
import smtplib
import sqlite3
import string
import os
import time
import face_recognition 
from flask import Flask, request, jsonify, send_from_directory, url_for, send_file
from flask_cors import CORS  # Allow Flutter API requests
from werkzeug.utils import secure_filename
import base64
import json
from PIL import Image
import io
import nltk
import vosk
import wave
from nltk.corpus import cmudict
from vosk import Model, KaldiRecognizer
import pronouncing
from collections import defaultdict
import cv2
import numpy as np


nltk.download('cmudict')
pron_dict = cmudict.dict()

user_mistakes = defaultdict(int)


app = Flask(__name__)  # Define Flask app first
CORS(app)  # Enable CORS
EASY_WORDS = [
    "apple", "ant", "bat", "cat", "dog", "egg", "owl", "ice", "up", "ear", "air",
    "eat", "arm", "exit", "aim", "map",  "rainbow"
]
MEDIUM_WORDS = [
    "ocean", "echo", "open", "idea", "under", "over", "inside", "oval", "upon",
    "evening", "always", "event", "banana", "tiger", "monkey", "violin", "school",
    "music", "island", "parrot", "thunder", "spaceship", "pyramid", "museum", 
    "treasure", "compass", "vacation", "detective", "puzzle", "library", "novel"
]
HARD_WORDS = [
    "octopus", "umbrella", "elephant", "astronaut", "universe", "engineer",
    "scientist", "electricity", "dinosaur", "waterfall", "jellyfish", "seahorse","starfish",
    "adventure", "mystery", "alphabet", "wizard", "enchant", "orchestra", "lighthouse"
]

LEVEL_WORDS = {
    "easy": EASY_WORDS,
    "medium": MEDIUM_WORDS,
    "hard": HARD_WORDS
}

ALL_WORDS = EASY_WORDS + MEDIUM_WORDS + HARD_WORDS
MODEL_PATH = "models/vosk-model-en-in-0.4"
vosk_model = vosk.Model(MODEL_PATH)
if not os.path.exists(MODEL_PATH):
    raise Exception("Vosk model not found! Download and place it in the project directory.")
model = Model(MODEL_PATH)
AUDIO_DIR = "datasets/audios/pronounce/"
UPLOAD_FOLDER = "profile_pics"
ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg"}
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER
os.makedirs(UPLOAD_FOLDER, exist_ok=True)  # Create folder if not exists

DATABASE = "users.db"
reset_codes = {}  # Store reset codes temporarily

# Email Configuration
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
SMTP_EMAIL = "techupport2363@gmail.com"
SMTP_PASSWORD = "qfhq tqyn lgdc icsz"  # Use an App Password

def compare_images(user_img, ref_img):
    # Resize and binarize both images
    user = cv2.resize(user_img, (ref_img.shape[1], ref_img.shape[0]))
    _, user_bin = cv2.threshold(user, 127, 255, cv2.THRESH_BINARY)
    _, ref_bin = cv2.threshold(ref_img, 127, 255, cv2.THRESH_BINARY)

    # Compute intersection and union
    intersection = np.logical_and(user_bin, ref_bin)
    union = np.logical_or(user_bin, ref_bin)

    accuracy = np.sum(intersection) / np.sum(union)
    return accuracy >= 0.85

@app.route('/next_word', methods=['GET'])
def next_word():
    level = request.args.get("level", "easy").lower()
    word_list = LEVEL_WORDS.get(level, EASY_WORDS)
    return jsonify({"word": random.choice(word_list)})

@app.route("/get_audio/<word>", methods=["GET"])
def get_audio(word):
    filepath = f"datasets/audios/pronounce/{word}.mp3"
    if os.path.exists(filepath):
        return send_file(filepath, mimetype="audio/mpeg")
    return jsonify({"error": "Audio not found"}), 404


# 2️⃣ **Get CMU Phonemes for a Word**
def get_cmu_phonemes(word):
    phonemes = pronouncing.phones_for_word(word)
    return phonemes[0].split() if phonemes else []


# 3️⃣ **Check Pronunciation Using Vosk & Phonemes**
@app.route("/check_pronunciation", methods=["POST"])
def check_pronunciation():
    word = request.form.get("word")
    audio = request.files.get("audio")

    if not word or not audio:
        return jsonify({"error": "Missing word or audio"}), 400

    # Save and convert audio to .wav
    audio_path = "temp_input.wav"
    audio.save(audio_path)

    wf = wave.open(audio_path, "rb")
    rec = KaldiRecognizer(model, wf.getframerate())

    recognized_text = ""
    while True:
        data = wf.readframes(4000)
        if len(data) == 0:
            break
        if rec.AcceptWaveform(data):
            result = json.loads(rec.Result())
            print(result)
            recognized_text += result.get("text", "").strip().lower() + " "

    
    final_result = json.loads(rec.FinalResult())
    recognized_text += final_result.get("text", "").strip().lower()
    wf.close()
    # Phoneme comparison
    expected_phonemes = pron_dict.get(word.lower(), [[]])[0]
    expected_cleaned = [p.lower().strip("0123456789") for p in expected_phonemes]

    recognized_phonemes = []
    for w in recognized_text.split():
        phs = pron_dict.get(w, [[]])[0]
        recognized_phonemes.extend(phs)

    recognized_cleaned = [p.lower().strip("0123456789") for p in recognized_phonemes]

    common = set(expected_cleaned).intersection(set(recognized_cleaned))
    similarity = len(common) / max(len(expected_cleaned), len(recognized_cleaned)) if expected_cleaned and recognized_cleaned else 0

    # Track phoneme mistakes
    missing_phonemes = list(set(expected_cleaned) - set(recognized_cleaned))
    for phoneme in missing_phonemes:
        user_mistakes[phoneme] += 1

    return jsonify({
    "recognized_text": recognized_text,
    "expected_phonemes": expected_cleaned,
    "recognized_phonemes": recognized_cleaned,
    "similarity": float(similarity),
    "missing_phonemes": missing_phonemes,
    "user_mistakes": dict(user_mistakes)
    })
@app.route("/get_practice_words", methods=["GET"])
def get_practice_words():
    level = request.args.get("level", "easy").lower()
    print(f"📥 Received request for practice words at level '{level}'")

    if not user_mistakes:
        print("⚠️ No user mistakes yet.")
        return jsonify({"message": "No common mistakes yet", "words": []})

    top_phoneme = max(user_mistakes.items(), key=lambda x: x[1])[0]
    print(f"🔎 Top mistaken phoneme: {top_phoneme}")

    word_list = LEVEL_WORDS.get(level, ALL_WORDS)

    matching_words = [
        word for word in word_list
        if top_phoneme in [p.lower().strip("0123456789") for p in pron_dict.get(word, [[]])[0]]
    ]
    print(f"📤 Practice words for level '{level}': {matching_words}")

    return jsonify({
        "problem_phoneme": top_phoneme,
        "words": matching_words[:3]
    })
@app.route('/play_phoneme_audio')
def play_phoneme_audio():
    phoneme = request.args.get('phoneme')
    filepath = f"datasets/phonemes/{phoneme}.wav"
    return send_file(filepath, mimetype="audio/wav")

# 4️⃣ **Play Correct Pronunciation Audio**
@app.route('/play_word_audio', methods=['GET'])
def play_audio():
    word = request.args.get('word', '').lower()
    audio_path = f"datasets/audios/pronounce/{word}.mp3"  # Ensure file exists

    if not os.path.exists(audio_path):
        return jsonify({"error": "Audio file not found"}), 400

    return send_file(audio_path, mimetype="audio/mpeg")


@app.route('/face_register', methods=['POST'])
def face_register():
    """Registers a user's face encoding in the database."""
    
    print("🔵 Request received at /face_register")  
    print("🔵 Request content type:", request.content_type)  
    print("🔵 Request files:", request.files)  
    print("🔵 Request form:", request.form)  

    # Check if the necessary fields are present
    if "face" not in request.files or "email" not in request.form:
        print("🔴 Error: Face image and email are required")
        return jsonify({"error": "Face image and email are required"}), 400

    file = request.files["face"]
    email = request.form.get("email")

    print(f"✅ Received email: {email}")
    print(f"✅ Received file: {file.filename}")

    # Check if the user exists
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute("SELECT id FROM users WHERE email = ?", (email,))
    user = cursor.fetchone()


    # Load the image
    try:
        image = face_recognition.load_image_file(file)
        face_encodings = face_recognition.face_encodings(image)
    except Exception as e:
        print(f"🔴 Error processing image: {str(e)}")
        return jsonify({"error": "Error processing image"}), 500

    if not face_encodings:
        print("🔴 Error: No face detected in the image")
        return jsonify({"error": "No face detected"}), 400

    face_encoding_str = json.dumps(face_encodings[0].tolist())  # Convert to JSON format
    print("✅ Face encoding generated successfully")

    # Store the face encoding in the database
    cursor.execute("UPDATE users SET face_encoding = ? WHERE email = ?", (face_encoding_str, email))
    conn.commit()
    conn.close()

    print("✅ Face encoding stored successfully in database")
    return jsonify({"message": "Face registered successfully"}), 200


def is_image(file):
    """Check if the file is a valid image."""
    try:
        Image.open(io.BytesIO(file.read()))
        file.seek(0)  # Reset file pointer after reading
        return True
    except Exception as e:
        print(f"Error: {e}")
        return False


def allowed_file(filename):
    """Check if the file type is allowed."""
    return "." in filename and filename.rsplit(".", 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/upload-profile-picture', methods=['POST'])
def upload_profile_picture():
    if "file" not in request.files:
        return jsonify({"error": "No file uploaded"}), 400

    file = request.files["file"]
    email = request.form.get("email")

    if not email:
        return jsonify({"error": "Email is required"}), 400

    if file.filename == "" or not allowed_file(file.filename) or not is_image(file):
        return jsonify({"error": "Invalid file type"}), 400

    filename = secure_filename(f"{email}.{file.filename.rsplit('.', 1)[1]}")
    filepath = os.path.join(app.config["UPLOAD_FOLDER"], filename)

    try:
        file.save(filepath)

        profile_url = url_for('serve_profile_picture', filename=filename, _external=True)

        conn = sqlite3.connect(DATABASE)
        cursor = conn.cursor()
        conn.execute('PRAGMA journal_mode=WAL;')
        cursor.execute("UPDATE users SET profile_picture = ? WHERE email = ?", (filename, email))
        conn.commit()
        conn.close()

        return jsonify({"message": "Profile picture uploaded successfully", "profile_picture": profile_url}), 200
    except Exception as e:
        print(f"Error saving file: {e}")
        return jsonify({"error": "Error uploading the file"}), 500
    
@app.route('/audio/pronounce/<path:filename>')
def serve_audio(filename):
    return send_from_directory('datasets/audios/pronounce', filename)


def get_db_connection():
    """Establish a database connection and return the connection object."""
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn


def generate_reset_code():
    """Generate a 4-digit random reset code."""
    return ''.join(random.choices(string.digits, k=4))  # Example: 1207


def generate_user_id():
    """Generate a 6-digit random user ID."""
    return random.randint(100000, 999999)  # Example: 234567


@app.route('/profile_pics/<filename>')
def serve_profile_picture(filename):
    """Serve profile pictures."""
    return send_from_directory(app.config["UPLOAD_FOLDER"], filename)


def send_email(to_email, reset_code):
    """Send email with the reset code."""
    try:
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(SMTP_EMAIL, SMTP_PASSWORD)
        message = f"Subject: Password Reset Code\n\nYour reset code is: {reset_code}"
        server.sendmail(SMTP_EMAIL, to_email, message)
        server.quit()
        print(f"📩 Reset code sent to {to_email}: {reset_code}")
    except Exception as e:
        print(f"❌ Email Error: {e}")


@app.route('/send-reset-code', methods=['POST'])
def send_reset_code():
    """Sends a reset code to the user's email."""
    data = request.json
    email = data.get("email")

    if not email:
        return jsonify({"error": "Email is required"}), 400

    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute("SELECT email FROM users WHERE email = ?", (email,))
    user = cursor.fetchone()

    if not user:
        conn.close()
        return jsonify({"error": "Email not registered"}), 404

    reset_code = str(random.randint(1000, 9999))
    reset_codes[email] = reset_code

    send_email(email, reset_code)

    cursor.execute('''
        INSERT OR REPLACE INTO reset_codes (email, code, created_at)
        VALUES (?, ?, CURRENT_TIMESTAMP)
    ''', (email, reset_code))

    conn.commit()  # Don't forget to commit the changes!
    conn.close()

    return jsonify({"message": "Reset code sent successfully"}), 200


@app.route('/register', methods=['POST'])
def register():
    """Registers a new user into the database."""
    data = request.json
    name, age = data.get('name'), data.get('age')
    email, password, level = data.get('email'), data.get('password'), data.get('level')
    profile_picture = data.get('profile_picture', None)

    if not name or not age or not email or not password or not level:
        return jsonify({"error": "All fields (name, age, email, password, level) are required"}), 400

    user_id = generate_user_id()

    try:
        conn = sqlite3.connect(DATABASE)
        cursor = conn.cursor()
        cursor.execute(""" 
            INSERT INTO users (id, name, age, email, password, level, profile_picture)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (user_id, name, age, email, password, level, profile_picture))
        conn.commit()
        conn.close()
        return jsonify({"message": "User registered successfully", "id": user_id}), 200
    except sqlite3.IntegrityError:
        return jsonify({"error": "Email already registered"}), 400

@app.route('/face_login', methods=['POST'])
def face_login():
    if 'face' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    image_file = request.files['face']
    image = face_recognition.load_image_file(image_file)
    face_encodings = face_recognition.face_encodings(image)

    if len(face_encodings) == 0:
        return jsonify({"error": "No face detected"}), 400

    new_encoding = np.array(face_encodings[0])  # Convert to NumPy array

    # Connect to SQLite
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute("SELECT email, name, level, face_encoding FROM users WHERE face_encoding IS NOT NULL")
    users = cursor.fetchall()
    conn.close()

    for user in users:
        stored_email, stored_name, stored_level, stored_encoding_str = user

        try:
            stored_encoding = np.array(json.loads(stored_encoding_str))  # Convert JSON string back to NumPy array
        except Exception as e:
            print(f"Error decoding stored face encoding: {e}")
            continue

        match = face_recognition.compare_faces([stored_encoding], new_encoding)[0]
        if match:
            return jsonify({
                "email": stored_email,
                "name": stored_name,
                "level": stored_level
            }), 200

    return jsonify({"error": "No matching face found"}), 401



@app.route('/login', methods=['POST'])
def login():
    """Handles user login."""
    data = request.json
    email, password = data.get('email'), data.get('password')

    if not email or not password:
        return jsonify({"error": "Email and password are required"}), 400

    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute("SELECT level FROM users WHERE email = ? AND password = ?", (email, password))
    user = cursor.fetchone()
    conn.close()

    if user:
        return jsonify({"message": "Login successful", "level": user[0]}), 200

    return jsonify({"error": "Invalid email or password"}), 401



@app.route('/reset-password', methods=['POST'])
def reset_password():
    data = request.json
    email = data.get('email')
    code = data.get('code')
    new_password = data.get('new_password')

    print(f"Received Email: {email}")
    print(f"Received Code: {code}")
    print(f"New Password: {new_password}")

    if not email or not code or not new_password:
        return jsonify({'error': 'Missing required fields'}), 400

    try:
        conn = sqlite3.connect('users.db')
        cursor = conn.cursor()

        # Debug check
        cursor.execute("SELECT * FROM reset_codes")
        print("All reset codes in DB:", cursor.fetchall())

        # Actual code check
        cursor.execute("SELECT * FROM reset_codes WHERE email = ? AND code = ?", (email, str(code)))
        result = cursor.fetchone()

        if not result:
            print("Code/email mismatch")
            return jsonify({'error': 'Invalid reset code'}), 400

        # Update password
        cursor.execute("UPDATE users SET password = ? WHERE email = ?", (new_password, email))
        conn.commit()

        # Delete reset code
        cursor.execute("DELETE FROM reset_codes WHERE email = ?", (email,))
        conn.commit()

        return jsonify({'message': 'Password reset successful'}), 200

    except Exception as e:
        print("Exception:", e)
        return jsonify({'error': 'Server error'}), 500

    finally:
        conn.close()






@app.route('/profile', methods=['GET'])
def profile():
    """Fetch the user's profile details."""  
    email = request.args.get("email")
    if not email:
        return jsonify({"error": "Email parameter is required"}), 400

    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute("SELECT name, age, email, level, profile_picture FROM users WHERE email = ?", (email,))
    user = cursor.fetchone()
    conn.close()

    if user:
        DEFAULT_PROFILE_PICTURE = "http://192.168.0.141:5000/profile_pics/default_avatar.png"
        
        if user[4]:  # If profile picture exists
            profile_picture_url = f"http://192.168.0.141:5000/profile_pics/{user[4]}?t={int(time.time())}"
        else:
            profile_picture_url = DEFAULT_PROFILE_PICTURE  # Use default avatar

        return jsonify({
            "name": user[0],
            "age": user[1],
            "email": user[2],
            "level": user[3],
            "profile_picture": profile_picture_url,  # Send full URL
        }), 200

    return jsonify({"error": "User not found"}), 404

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
