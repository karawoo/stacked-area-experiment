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
    
    # Create paths for training task and main task. Eventually we'll choose
    # between these based on whether we've seen the user before
    task_path = "/task" + path[1:]
    train_path = "/training" + path[1:]

    # Test out selectively redirecting users using a dummy arg that I'll put in
    # the request
    test = request.args["test"]
    if test == "new":
        return render_template("intro.html", path = train_path)
    elif test == "seenbefore":
        return render_template("intro.html", path = task_path)

    
# Serve chart images
@app.route("/charts/<path:path>")
def serve_charts(path):
    return send_from_directory("static/images", path)


# Extract MTurk variables
def get_ids():
    # Try to get them from the request args
    hit_id = request.args.get("hitId")
    assignment_id = request.args.get("assignmentId")
    worker_id = request.args.get("workerId")

    # If that didn't work (i.e. because there were no args), get them from the
    # training task form data
    if not any([hit_id, assignment_id, worker_id]):
            hit_id = request.form.get("hitId")
            assignment_id = request.form.get("assignmentId")
            worker_id = request.form.get("workerId")

    # If there are still no values, throw an error
    if not any([hit_id, assignment_id, worker_id]):
        raise ValueError("Could not find hitId, assignmentId, and workerId")
    
    return hit_id, assignment_id, worker_id

     
# Show training task
@app.route("/training")
def serve_training():
    train_img = "stacked_area_TEST_1.png"
    train_imgpath = "charts/" + train_img

    # Get workerId etc. from request
    hit_id, assignment_id, worker_id = get_ids()

    return render_template("training.html", train_image_url = train_imgpath,
                           hit_id = hit_id, assignment_id = assignment_id,
                           worker_id = worker_id)


# Show a task with a (for now) hard-coded image
@app.route("/task", methods = ["POST", "GET"])
def serve_task():
    img = "stacked_area_decreasing_0.825_A.png"
    imgpath = "charts/" + img

    # Get the training task data, or set to empty strings if there is no form
    # (i.e. no training task)
    Q1 = request.form.get("Q1", "")
    Q2 = request.form.get("Q2", "")
    Q3 = request.form.get("Q3", "")

    # Get MTurk variables
    hit_id, assignment_id, worker_id = get_ids()
    
    return render_template("task.html", image_url = imgpath, Q1 = Q1, Q2 = Q2,
                           Q3 = Q3, hit_id = hit_id, assignment_id =
                           assignment_id, worker_id = worker_id)


if __name__ == '__main__':
    app.run()
    
