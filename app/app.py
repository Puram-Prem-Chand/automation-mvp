from flask import Flask
app = Flask(__name__)

@app.route("/")
def index():
    return "Hello — automation MVP is live!\n"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)