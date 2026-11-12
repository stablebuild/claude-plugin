import sys

import numpy as np
import tensorflow as tf
from PIL import Image

content_path, style_path = sys.argv[1], sys.argv[2]
vgg = tf.keras.applications.VGG19(include_top=False, weights="imagenet")
print("loaded VGG19 with", len(vgg.layers), "layers for", content_path, style_path, np.__version__)
