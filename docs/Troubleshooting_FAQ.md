# Troubleshooting / FAQ

## Focus Points Viewer ##

* [No focus points recorded](#No-focus-points-recorded)
* [Manual focus, no AF points recorded](#Manual-focus-no-AF-points-recorded)
* [Focus info missing from file](#Focus-info-missing-from-file)
* [Camera model not supported](#Camera-model-not-supported)
* [Camera maker not supported](#Camera-maker-not-supported)
* [Errors encountered](#Errors-encountered)

## General

* [Plugin window exceeds screen dimensions](#Plugin-window-exceeds-screen-dimensions)


## Focus Points Viewer

### "No focus points recorded"
The camera was set to use autofocus (AF) but did not focus when the image was captured. Information about "in focus" AF points is not available in the metadata; it was not recorded by the camera.

The exact reason for this behavior may depend on the specific camera model and the way the camera manufacturer has designed the AF system to work. Check the log file for details.

A common potential reason for this situation is that the AF system has not completed its task.

Take a look at the example below (Olympus camera). The shot was taken with "Release Priority", "AF Search" was "not ready". However, the shot looks sharp. Maybe the AF system just didn't finish fine-tuning the focus.

<img src="../screens/Troubleshooting 1.jpg" alt="User Interface (Multi-image)" style="width: 800px;"/>

Log file:

<img src="../screens/Troubleshooting 2.jpg" alt="User Interface (Multi-image)" style="width: 800px;"/>


### "Manual focus, no AF points recorded"
This is a special but very typical case of "No focus points recorded". The photo was taken with manual focus (MF), so there is no autofocus (AF) information in the metadata.

<img src="../screens/Troubleshooting 3.jpg" alt="User Interface (Multi-image)" style="width: 800px;"/>


### "Focus info missing from file"

The selected photo lacks the metadata needed to process and visualize focus information. This error message typically occurs when you try to view focus points for an image that was processed outside of Lightroom (for example, in Photoshop).

Why is this happening?
The plugin requires the metadata of original, out-of-camera JPGs or RAW files in order to work. Focus information, along with many other camera-specific settings, is stored in _makernotes_, a manufacturer-specific section of the EXIF metadata.
Lightroom does not retain or even read makernotes when importing files. Therefore, if a separate file is created from the original image (e.g. by exporting to another application such as Photoshop), this information will not be present in the file and the plugin will not have the necessary inputs to work.


For more details and concrete examples, see [Scope and Limitations](Focus%20Points.md#scope-and-limitations).  

For example, this image was imported into Lightroom as a RAW file and then edited in Photoshop. The re-imported TIFF file is missing the makernotes and focus information, so the plugin does not have the data it needs to work.

<img src="../screens/Troubleshooting 6.jpg" alt="User Interface (Multi-image)" style="width: 800px;"/>

The log file reveals which tag has not been found in metadata:

<img src="../screens/Troubleshooting 7.jpg" alt="User Interface (Multi-image)" style="width: 800px;"/>


### "Camera model not supported"

The selected photo was taken by a camera that the plugin cannot handle.

This message may be displayed for older camera models that do not use the same structures to store AF-related information as their successor models. It can also be displayed for newer models where the AF related information has not yet been decoded by ExifTool.

Example for 'ancient' Olympus E-510:

<img src="../screens/Troubleshooting 4.jpg" alt="User Interface (Multi-image)" style="width: 800px;"/>


### "Camera maker not supported"

The selected photo was taken with a camera from a manufacturer that the plugin cannot handle.

While it is not difficult to add at least basic support for a camera brand, this requires that the relevant AF metadata be available. This means they have to be "known" by exifool, which is not the case for Leica, Hasselblad, Sigma, Samsung phones and others.

<img src="../screens/Troubleshooting 5.jpg" alt="User Interface (Multi-image)" style="width: 800px;"/>


### "Errors encountered"

This message is displayed when something unexpected happens during the process of reading focus information from metadata, processing it, and displaying the visualization elements.

This can be anything from installation problems, corrupt metadata, or simply that the programmer failed to properly handle a certain situation in that code. The log file may give some indication of what the problem is, but usually it is not something a user can fix.

If you run into this problem and cannot fix it yourself, you will be asked to go to the plugin page, sign up for a free account, and [create a new issue](https://github.com/musselwhizzle/Focus-Points/issues) that describes the problem.


Example error:

<img src="../screens/Troubleshooting 8.jpg" alt="User Interface (Multi-image)" style="width: 800px;"/>

The log file reveals what the problem is (artificially induced to provoke this error message ;)

<img src="../screens/Troubleshooting 9.jpg" alt="User Interface (Multi-image)" style="width: 800px;"/>


## General 

### Plugin window exceeds screen dimensions

to be completed
