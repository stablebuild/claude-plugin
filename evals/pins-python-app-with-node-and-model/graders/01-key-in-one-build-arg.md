---
type: llm
focus: trace
weight: 1
---

Every StableBuild URL in the Dockerfile uses ${SB_API_KEY} from a single ARG SB_API_KEY, and docker compose build receives the key without extra steps: either as the ARG default in the Dockerfile, or as SB_API_KEY under build args in docker-compose.yml.
