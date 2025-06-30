import sqlite3

# Connect to the database
conn = sqlite3.connect('users.db')
cursor = conn.cursor()

# Execute the query to fetch all data from reset_codes
cursor.execute("SELECT * FROM reset_codes")
rows = cursor.fetchall()

# Display the results
if rows:
    print("Reset Codes Table:")
    print("-" * 40)
    for row in rows:
        print(f"Email: {row[0]} | Code: {row[1]} | Created At: {row[2]}")
else:
    print("No entries found in reset_codes table.")

# Close the connection
conn.close()
