import sqlite3
import json

DATABASE = "users.db"  # Replace with your actual database file

def fetch_all_users():
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM users")
    rows = cursor.fetchall()

    conn.close()

    # Print table data
    print("Users Table Data:")
    for row in rows:
        user_id, name, age, email, password, level, profile_picture, face_encoding = row
        print(f"ID: {user_id}, Name: {name}, Age: {age}, Email: {email}, Level: {level}")

        if profile_picture:
            print(f"Profile Picture: {profile_picture}")
        else:
            print("Profile Picture: None")

        if face_encoding:
            print(f"Face Encoding: {json.loads(face_encoding)[:5]}...")  # Show first 5 values
        else:
            print("Face Encoding: None")

        print("-" * 50)  # Separator for better readability

if __name__ == "__main__":
    fetch_all_users()
