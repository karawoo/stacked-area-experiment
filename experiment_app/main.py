from flask import Flask, render_template, send_from_directory, request

app = Flask(__name__)
app.debug = True                # Turn on some extra logging

# Show the introductory page first (with info about the study)
@app.route("/")
def intro():
    # Get the path that is passed in from the MTurk request. This contains
    # assignmentId etc., which we need to pass on to the next page in order to
    # capture and return it with the worker's answers.
    path = request.full_path
    # Create paths for training task and main task. Eventually we'll choose between these based on whether we've seen the user before?
    task_path = "/task" + path[1:]
    train_path = "/training" + path[1:]
    return render_template("intro.html", path = train_path)  # Hard-coded to train path for now

# Serve chart images
@app.route("/charts/<path:path>")
def serve_charts(path):
    return send_from_directory("static/images", path)

# Show training task
@app.route("/training")
def serve_training():
    train_img = "stacked_area_TEST_1.png"
    train_imgpath = "charts/" + train_img

    # Get workerId etc. from request
    hit_id = request.args["hitId"]
    assignment_id = request.args["assignmentId"]
    worker_id = request.args["workerId"]

    return render_template("training.html", train_image_url = train_imgpath,
                           hit_id = hit_id, assignment_id = assignment_id,
                           worker_id = worker_id)

# Show a task with a (for now) hard-coded image
@app.route("/task", methods = ["POST"])
def serve_task():
    img = "stacked_area_decreasing_0.825_A.png"
    imgpath = "charts/" + img

    if request.method == "POST":
        # Answers to Q1 and Q2
        Q1 = request.form["Q1"]
        Q2 = request.form["Q2"]
        
        # Get workerId etc. from request
        hit_id = request.form["hitId"]
        assignment_id = request.form["assignmentId"]
        worker_id = request.form["workerId"]
    
    return render_template("task.html", image_url = imgpath, Q1 = Q1, Q2 = Q2,
                           hit_id = hit_id, assignment_id = assignment_id,
                           worker_id = worker_id)

if __name__ == '__main__':
    app.run()
    
