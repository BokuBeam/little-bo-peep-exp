/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./frontend/src/*.{html,js,ts,elm}",
  ],
  theme: {
    extend: {
      fontFamily: {
        'audiowide': ['Audiowide'],
        'baskerville': ['Baskerville Regular'],
        'baskerville-bold': ['Baskerville Bold'],
        'baskerville-italic': ['Baskerville Italic'],
        'clickerscript': ['Clicker Script'],
        'indieflower': ['IndieFlower'],
        'menlo': ['Menlo'],
        'pollerone': ['PollerOne'],
        'princessjohn': ['PrincessJohn'],
        'songmyung': ['SongMyung'],
        'tomorrow': ['Tomorrow']
      },
      width: {
        '128': '32rem',
        '192': '48rem',
        '256': '64rem',
        '384': '96rem',
        '512': '128rem',
        '3/1': '300%'
      },
      strokeWidth: {
        '1': '1.5px',
        '2': '3px',
      }
    },
  },
  plugins: [],
}
