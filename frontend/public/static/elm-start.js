// Prevent browser adjusting scroll position on refresh
history.scrollRestoration = "manual"

const root = document.getElementById("root");
let app = window.Elm.Main.init({ node: root });

app.ports.onLoad.subscribe(function() {
  document.querySelector("#Header").scrollIntoView({ block: "start", inline: "start" });
});

initMath(app);

