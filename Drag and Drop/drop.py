from flask import Flask, render_template, request
import argparse

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ip = input("Enter the IP: ")
    port = int(input("Enter the Port: "))
    args = vars(ap.parse_args())
    x = 0
    while x == 0:
        debug = input("Debug Mode (changes to local only)? (y/n): ")
        if debug == "y" or debug == "n":
            x = 1
        else:
            print("Invalid Response")
    if debug == "y":
        debug = True
    elif debug == "n":
        debug == False
    app.run(host=ip, port=port, debug=debug, threaded=True, use_reloader=False)