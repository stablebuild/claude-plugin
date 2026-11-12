---
type: llm
focus: trace
weight: 1
---

get-pip.py is downloaded through httpcache.stablebuild.com, and both get-pip.py and the onnx install use -i https://${SB_API_KEY}.pypimirror.stablebuild.com/<YYYY-MM-DD>/ (or the same with a PYPI_PIN_DATE arg).
