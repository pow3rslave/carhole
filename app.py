from flask import Flask, render_template, Response
from picamera2 import Picamera2
from libcamera import Transform
import cv2
import threading

app = Flask(__name__)
picam2 = Picamera2()

# Rotate video 180 degrees (horizontal + vertical flip)
transform = Transform(hflip=True, vflip=True)
picam2.configure(picam2.create_video_configuration(
    main={"size": (640, 480)},
    transform=transform
))
picam2.start()

def gen_frames():
    while True:
        frame = picam2.capture_array()
        ret, buffer = cv2.imencode('.jpg', frame)
        if not ret:
            continue
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + buffer.tobytes() + b'\r\n')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/video_feed')
def video_feed():
    return Response(gen_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8081)
