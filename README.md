## Development

To install the needed frontend tooling, you will need a recent version of Node installed. Then run:
`
  npm install
`

A run script containing all of the different watchers can be run with:
`
  npm start
`
This uses `concurrently` to run and report the output from the different build tools in watch mode. A server will start on localhost:8080.

## Docker

To build the image, run:
`
DOCKER_BUILDKIT=1 docker build -t little-bo-peep-exp .
`

To run the Docker container locally, run:
`
docker run -dp 8080:8080 little-bo-peep-exp
`