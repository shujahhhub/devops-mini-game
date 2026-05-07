import random
import socket
from flask import Flask, request, render_template_string

app = Flask(__name__)

# The HTML template for the game
HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>DevOps HA Game</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
        .pod { color: #007bff; font-weight: bold; }
        .msg { font-size: 24px; margin-top: 20px; }
    </style>
</head>
<body>
    <h1>🎯 The DevOps Mini-Game</h1>
    <p>Guess a number between 1 and 5.</p>
    
    <h3>Currently Served by Pod: <span class="pod">{{ pod_name }}</span></h3>
    
    <form method="POST">
        <input type="number" name="guess" min="1" max="5" required style="padding: 5px; font-size: 16px;">
        <button type="submit" style="padding: 5px 15px; font-size: 16px; cursor: pointer;">Guess</button>
    </form>
    
    <div class="msg">{{ message }}</div>
</body>
</html>
"""

@app.route('/', methods=['GET', 'POST'])
def game():
    # socket.gethostname() grabs the Docker Container ID (Pod Name in Kubernetes)
    pod_name = socket.gethostname() 
    message = "Waiting for your guess..."
    
    if request.method == 'POST':
        guess = int(request.form.get('guess'))
        target = random.randint(1, 5)
        
        if guess == target:
            message = f"🎉 YOU WON! The number was {target}."
        else:
            message = f"❌ Incorrect! The number was {target}. Try again."
            
    return render_template_string(HTML, pod_name=pod_name, message=message)

# Kubernetes requires a 'Health Check' endpoint to know if the container is alive
@app.route('/health')
def health():
    return "OK", 200

if __name__ == '__main__':
    # Listen on all network interfaces inside the container
    app.run(host='0.0.0.0', port=5000)