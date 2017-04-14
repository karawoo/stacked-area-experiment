# Stacked Area Graphical Perception Experiment

This repo contains an experiment to test viewers' perception of stacked area
charts. Currently written as a Flask app, the experiment shows information about
the study (including contact information), then takes viewers to a page where
they are presented with a chart and are asked to answer a few questions about
it.

[`chart_generator.R`](chart_generator.R) is the file that creates the chart
images.

The [`experiment_app/`](experiment_app/) folder has the code for the experiment
itself.

Currently the app is running at https://salty-shore-16410.herokuapp.com.
However, to progress beyond the first page you need a URL like
https://salty-shore-16410.herokuapp.com/?train=charts/stacked_area_TEST_3.png&task=charts/stacked_area_decreasing_0.825_A.png&assignmentId=67483929810ASLDKFJ929&workerId=295JS1LSDKFJSQ&hitId=123RVWYBAZW00EXAMPLE.
These parameters get sent on to the next page so that they can be returned along
with the workers' results.
