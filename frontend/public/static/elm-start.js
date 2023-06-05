const root = document.getElementById('root');
const app = window.Elm.Main.init({ node: root });
document.querySelector('#Header').scrollIntoView({ block: 'start', inline: 'start' });
