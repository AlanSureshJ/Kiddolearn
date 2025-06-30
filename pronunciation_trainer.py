import os
import random
import json
import nltk
import pyaudio
import pygame
import time
from vosk import Model, KaldiRecognizer
from nltk.corpus import cmudict
from pydub import AudioSegment
import threading

# Download phoneme dictionary
nltk.download('cmudict')
pron_dict = cmudict.dict()

# Word bank
WORD_LIST = ["apple", "eagle", "orange", "ice", "ocean", "ear", "owl", "igloo", "octopus", "elephant",
             "air", "eat", "open", "idea", "up", "iguana", "ant", "egg", "onion", "under",
             "arm", "oven", "echo", "umbrella", "ape", "aim", "ear", "over", "inside", "ox",
             "exit", "out", "animal", "age", "uncle", "eager", "orbit", "event", "always",
             "everyone", "invite", "agree", "easy", "oval", "upon", "air", "evening", "alarm", "overtake"]

# Vosk model setup
MODEL_PATH = "models/vosk-model-en-in-0.4"
model = Model(MODEL_PATH)
recognizer = KaldiRecognizer(model, 16000)

# PyAudio setup
def create_stream():
    p = pyaudio.PyAudio()
    stream = p.open(format=pyaudio.paInt16, channels=1, rate=16000, input=True, frames_per_buffer=8192)
    stream.start_stream()
    return p, stream

p, stream = create_stream()  # Initialize

# Game variables
NUM_WORDS = 5
word_list = random.sample(WORD_LIST, NUM_WORDS)
word_index = 0

pygame.mixer.init()
SLOW_AUDIO_FOLDER = "datasets/audios/pronounce/slow/"
PHONEME_AUDIO_FOLDER = "datasets/phonemes/"
os.makedirs(SLOW_AUDIO_FOLDER, exist_ok=True)

# Restart stream safely
def restart_stream():
    global p, stream
    try:
        if stream.is_stopped():
            stream.start_stream()
    except Exception:
        p, stream = create_stream()

# Play phoneme audio (uppercase filenames)
def play_phoneme_audio(phoneme):
    phoneme_audio_path = os.path.join(PHONEME_AUDIO_FOLDER, f"{phoneme.upper()}.wav")
    if os.path.exists(phoneme_audio_path):
        pygame.mixer.music.load(phoneme_audio_path)
        pygame.mixer.music.play()
        return f"Playing phoneme: {phoneme.upper()}"
    return f"Phoneme audio not found: {phoneme_audio_path}"

# Play word audio
def play_word_audio(word, slow=False):
    normal_audio_path = f"datasets/audios/pronounce/{word}.mp3"
    slow_audio_path = os.path.join(SLOW_AUDIO_FOLDER, f"{word}_slow.wav")  

    if not os.path.exists(normal_audio_path):
        return f"Audio file not found: {normal_audio_path}"

    if slow and not os.path.exists(slow_audio_path):
        sound = AudioSegment.from_file(normal_audio_path)
        slowed_sound = sound.set_frame_rate(int(sound.frame_rate * 0.5))
        slowed_sound.export(slow_audio_path, format="wav")

    audio_path = slow_audio_path if slow else normal_audio_path
    pygame.mixer.music.load(audio_path)
    pygame.mixer.music.play()
    return "Playing correct pronunciation..."

# Get phoneme representation from cmudict
def get_phonemes(word):
    return pron_dict.get(word.lower(), [])

# Check pronunciation
def check_pronunciation():
    restart_stream()

    expected_word = word_list[word_index].lower()
    expected_phonemes = get_phonemes(expected_word)

    recognized_text = ""
    start_time = time.time()

    while time.time() - start_time < 5:
        try:
            data = stream.read(4000, exception_on_overflow=False)
            if recognizer.AcceptWaveform(data):
                result = json.loads(recognizer.Result())
                recognized_text = result.get("text", "").strip().lower()
                if recognized_text:
                    break
        except OSError:
            restart_stream()
            return "Stream error, please try again."

    if not recognized_text:
        return "No speech detected! Try again."

    recognized_phonemes_list = []
    for word in recognized_text.split():
        phonemes = get_phonemes(word)
        if phonemes:
            recognized_phonemes_list.extend(phonemes[0])

    recognized_cleaned = [p.lower().strip("0123456789") for p in recognized_phonemes_list]
    expected_cleaned = [p.lower().strip("0123456789") for p in expected_phonemes[0]] if expected_phonemes else []

    common = set(expected_cleaned).intersection(set(recognized_cleaned))
    similarity = len(common) / max(len(expected_cleaned), len(recognized_cleaned)) if expected_cleaned and recognized_cleaned else 0

    if similarity == 1.0:
        return "Perfect pronunciation! Well done!"
    else:
        missing_phonemes = list(set(expected_cleaned) - set(recognized_cleaned))
        return {"message": "Try again! Incorrect phonemes.", "missing_phonemes": missing_phonemes}

# Load the next word
def next_word():
    global word_index, word_list

    word_index += 1
    if word_index >= len(word_list):
        word_index = 0
        random.shuffle(word_list)  

    return {"word": word_list[word_index], "message": "Say the word!"}

# API Integration Example
if __name__ == "__main__":
    print(next_word())  # Test: Get first word
    print(play_word_audio(word_list[word_index]))  # Test: Play audio
    print(check_pronunciation())  # Test: Check pronunciation
