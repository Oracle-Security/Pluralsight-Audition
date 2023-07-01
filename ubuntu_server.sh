#Install Dependencies
#!/bin/bash

# Update the system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install python3 and pip
sudo apt-get install python3 python3-pip -y

# Create application directory
mkdir ~/flask_app
cd ~/flask_app

#Install dependencies 
pip3 install flask

# Create the app
cat > app.py << 'EOF'
from flask import Flask, render_template_string, request

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def index():
    greeting = "Welcome!"
    if request.method == 'POST':
        name = request.form.get('name')
        greeting = render_template_string(f"Hello, {name}!")
    return render_template_string('''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TechGuru - Your Tech Companion</title>
    <!-- CSS only -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css">
    <style>
        .navbar {
            background-color: #ff9800;
        }
        .navbar-brand, .nav-link {
            color: #ffffff;
        }
        .btn-primary {
            background-color: #4caf50;
            border-color: #4caf50;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg">
        <a class="navbar-brand" href="#">TechGuru</a>
        <div class="collapse navbar-collapse">
            <ul class="navbar-nav mr-auto">
                <li class="nav-item active">
                    <a class="nav-link" href="#">Home <span class="sr-only">(current)</span></a>
                </li>
            </ul>
        </div>
    </nav>
    <div class="container">
        <h1 class="mt-5">Welcome to TechGuru</h1>
        <p class="mt-4">At TechGuru, we aim to guide you through the complex world of technology. Get personalized tech insights now!</p>
        <form method="POST" class="mt-4">
            <div class="form-group">
                <label for="name">Enter your name for personalized insights</label>
                <input type="text" class="form-control" id="name" name="name">
            </div>
            <button type="submit" class="btn btn-primary">Get Insights!</button>
        </form>
        <h2 class="mt-4">{{ greeting }}</h2>
    </div>
    <!-- JS, Popper.js, and jQuery -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
    ''', greeting=greeting)


if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)
EOF

#Start the application
python3 app.py