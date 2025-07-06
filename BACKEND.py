import mysql.connector
import bcrypt

# Establish Connection
db = mysql.connector.connect(
    host="localhost",
    user="root",  # Ensure 'root' has access to the 'FIT' database
    password="Badri@786226141",  # Update this with your actual MySQL password
    database="FIT"
)
cursor = db.cursor()

# Initialize user_id globally
user_id = None

# ✅ Password Hashing
def hash_password(password):
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

def check_password(stored_hash, entered_password):
    return bcrypt.checkpw(entered_password.encode(), stored_hash.encode())

# 1️⃣ User Registration
def register_user(name, email, password, age, gender, height_cm, weight_kg, phone_number, address):
    hashed_password = hash_password(password)
    cursor.execute("""
        INSERT INTO Users (name, email, password_hash, age, gender, height_cm, weight_kg, phone_number, address)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (name, email, hashed_password, age, gender, height_cm, weight_kg, phone_number, address))
    
    db.commit()
    print("✅ User Registration Successful!")

# 2️⃣ User Login
def login_user(email, password):
    global user_id  
    cursor.execute("SELECT user_id, password_hash, role FROM Users WHERE email=%s", (email,))
    
    user = cursor.fetchone()
    
    if user and check_password(user[1], password):
        cursor.execute("UPDATE Users SET last_login = NOW() WHERE user_id = %s", (user[0],))
        db.commit()
        print(f"✅ Login Successful! (Role: {user[2]})")  # Show role after login
        user_id = user[0]
    else:
        print("❌ Invalid Credentials!")
        user_id = None

# 3️⃣ Log Workout
def log_workout(workout_type, duration_minutes, calories_burned, intensity, heart_rate_avg, workout_notes):
    global user_id
    if user_id is None:
        print("❌ Please login first!")
        return
    
    valid_intensity = ["Low", "Medium", "High"]
    if intensity not in valid_intensity:
        print("❌ Invalid Intensity! Use: Low, Medium, or High.")
        return
    
    cursor.execute("""
        INSERT INTO Workouts (user_id, workout_date, workout_type, duration_minutes, calories_burned, intensity, heart_rate_avg, workout_notes)
        VALUES (%s, CURDATE(), %s, %s, %s, %s, %s, %s)
    """, (user_id, workout_type, duration_minutes, calories_burned, intensity, heart_rate_avg, workout_notes))
    
    db.commit()
    print("✅ Workout Logged Successfully!")

# 4️⃣ Retrieve Workout History
def get_workout_history():
    global user_id
    if user_id is None:
        print("❌ Please login first!")
        return
    
    cursor.execute("""
        SELECT workout_date, workout_type, duration_minutes, calories_burned, intensity, heart_rate_avg, workout_notes
        FROM Workouts WHERE user_id = %s ORDER BY workout_date DESC
    """, (user_id,))
    
    workouts = cursor.fetchall()
    if workouts:
        print("\n📌 Workout History:")
        for w in workouts:
            print(f"📅 {w[0]} | 🏋️ {w[1]} | ⏳ {w[2]} min | 🔥 {w[3]} cal | ⚡ {w[4]} | 💓 {w[5]} bpm | 📝 {w[6]}")
    else:
        print("❌ No workouts found for this user.")
       
# 5️⃣ Admin Functions
def view_all_users():
    cursor.execute("SELECT user_id, name, email, role FROM Users ORDER BY user_id")
    users = cursor.fetchall()
    
    print("\n📋 User List:")
    for u in users:
        print(f"🆔 {u[0]} | 👤 {u[1]} | 📧 {u[2]} | 🏅 {u[3]}")

def delete_user(target_user_id):
    global user_id

    if user_id is None:
        print("❌ Please login first!")
        return

    cursor.execute("SELECT role FROM Users WHERE user_id = %s", (user_id,))
    role = cursor.fetchone()

    if not role:
        print("❌ Invalid User! Please login.")
        return

    if role[0].lower() != 'admin':
        print("❌ Only admins can delete users!")
        return

    cursor.execute("SELECT * FROM Users WHERE user_id = %s", (target_user_id,))
    user_exists = cursor.fetchone()

    if user_exists:
        cursor.execute("DELETE FROM Users WHERE user_id = %s", (target_user_id,))
        db.commit()
        print(f"✅ User ID {target_user_id} deleted successfully!")
    else:
        print("❌ User not found!")

# **Menu for Testing**
while True:
    print("\n🏋️ FITNESS MANAGEMENT SYSTEM 🏋️")
    print("1️⃣ Register User")
    print("2️⃣ Login User")
    print("3️⃣ Log Workout")
    print("4️⃣ View Workout History")
    print("5️⃣ View All Users (Admin)")
    print("6️⃣ Delete User (Admin)")
    print("0️⃣ Exit")

    choice = input("Enter your choice: ")

    if choice == "1":
        register_user(
            input("Enter Name: "),
            input("Enter Email: "),
            input("Enter Password: "),
            int(input("Enter Age: ")),
            input("Enter Gender (Male/Female/Other): "),
            float(input("Enter Height (cm): ")),
            float(input("Enter Weight (kg): ")),
            input("Enter Phone Number: "),
            input("Enter Address: ")
        )
    elif choice == "2":
        login_user(input("Enter Email: "), input("Enter Password: "))
    elif choice == "3":
        log_workout(
            input("Enter Workout Type: "),
            int(input("Enter Duration (min): ")),
            float(input("Enter Calories Burned: ")),
            input("Enter Intensity (Low, Medium, High): "),
            int(input("Enter Avg Heart Rate: ")),
            input("Enter Workout Notes: ")
        )
    elif choice == "4":
        get_workout_history()
    elif choice == "5":
        view_all_users()
    elif choice == "6":
        delete_user(int(input("Enter User ID to Delete: ")))
    elif choice == "0":
        print("🚀 Exiting... Goodbye!")
        cursor.close()
        db.close()
        break
