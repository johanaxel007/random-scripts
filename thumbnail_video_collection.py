"""
Finds recursively all videos in a directory, and produces a webpage with a frame for every 30 minutes of video.
A Python primer of gathering basic video information using ffprobe, and reading JPEG-encoded frames using ffmpeg.

Usage: python thumbnail_video_collection.py /path/to/video/dir > thumbnail.html

Parameters:
--skip_seconds: default 1800 seconds (30 minutes)
--thumb_size: 320x240
--video_extension: mp4


Converted to Python 3 using Modernize & pyupgrade
Original Python 2 source: https://gist.github.com/vadimkantorov/0f4a2060f1dc245e6ad0e019b99d59ee
"""

import os
import sys
import json
import subprocess
import datetime
import argparse
import base64
import html

parser = argparse.ArgumentParser()
parser.add_argument('video_dir')
parser.add_argument('--skip_seconds', type = int, default = 30 * 60)
parser.add_argument('--thumb_size', default = '320x240')
parser.add_argument('--video_extension', default = ['mp4','mkv','mov','flv','avi','wmv','mpg','mpeg','m4v','webm'], action = 'append')
args = parser.parse_args()

def safe_list_get (l, idx, default):
  try:
    return l[idx]
  except IndexError:
    return default

video_paths = sorted([os.path.join(root, file) for root, _, files in os.walk(args.video_dir) for file in files for ext in args.video_extension if file.endswith(ext)])

print('<html><body><table border="1px">')
for video_index, video_path in enumerate(video_paths):
    print(video_index + 1, '/', len(video_paths), os.path.basename(video_path), file=sys.stderr)

    ffprobe = subprocess.check_output(['ffprobe', '-v', 'quiet', '-print_format', 'json', '-show_streams', video_path])
    frame_width, frame_height, codec_name, duration = safe_list_get([(stream.get('width', 0), stream.get('height', 0), stream.get('codec_name', 'Unknown'), int(float(stream.get('duration', 0)))) for stream in json.loads(ffprobe)['streams'] if stream['codec_type'] == 'video'], 0, [0, 0, 'Unknown', 0])

    print('<tr>')
    print(''.join(map('<td style="white-space:nowrap">{}</td>'.format, ['#%d' % (video_index + 1), 'W%d' % frame_width, 'H%d' % frame_height, codec_name, datetime.timedelta(seconds = duration)] + str(video_path.encode('utf-8', 'xmlcharrefreplace')).removeprefix("b'").removesuffix("'").split('/'))))
    for ss in range(0, duration - args.skip_seconds, args.skip_seconds):
        # this explicit iteration with fast seeks is 10x faster than "-skip_frame nokey -vf fps=1/1800"
        jpeg = subprocess.check_output(['ffmpeg', '-v', 'quiet', '-ss', str(ss), '-i', video_path, '-s', args.thumb_size, '-an', '-f', 'image2pipe', '-c:v', 'mjpeg', '-q:v', '1', '-frames:v', '1', '-'])
        
        print('<td><img src="data:image/jpeg;base64,%s" /></td>' % base64.b64encode(jpeg).decode('utf-8'))
    print('</tr>')
print('</table></body></html>')
