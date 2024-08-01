# CatEars

CatEars is a small HTTP listener, born from my frustrations with Burp
Collaborator's limitations and cost. It was originally written in Racket,
and ported to Gleam as much out of curiosity as anything else. The Gleam
implementation turned out to have significantly lower baseline memory
requirements, and I found Gleam very pleasant to write, so it replaced
the original.

I've found it quite helpful for CTF challenges involving SSRF and XSS.

Please use responsibly :)

## Deployment

The included `Dockerfile` should work nicely with various cloud services,
or it can be run behind a reverse proxy like Ngrok. It listens on port 8080
by default.

Example configs are included for cloud services I've used to deploy CatEars.

### Google Cloud Run

1. `cp service.example.yaml service.yaml`
2. edit container image URL to point to your container image
3. `gcloud run services replace ./service.yaml`

CatEars fits in the smallest supported instance specs, and is meant to fit
within Cloud Run's free tier for normal pentest/bug-bounty use.

### Fly.io

`fly launch` in the top-level project directory will deploy CatEars with
Fly.io's minimum supported infrastructure specs (afaik).

_note: Fly.io doesn't have a "free tier" like GCP/AWS, but they_
_sponsor Gleam and I think that's pretty cool._

## Development

I built this for myself, and open-sourced it in case someone else might
find it useful. Issues and PRs are welcome, but please keep in mind that
I have a day job and make take a day or three to respond.

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
