const root = document.getElementById("root");
let app = window.Elm.Main.init({ node: root });

app.ports.onLoad.subscribe(function() {
  console.log("Elm loaded");
  // document.querySelector("#Header").scrollIntoView({ block: "start", inline: "start" });
});

initMath(app);