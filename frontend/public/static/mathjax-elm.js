const initMath = async function(app) {
  var mathjaxJs = document.createElement('script')
  mathjaxJs.type = 'text/javascript'
  mathjaxJs.src = 'https://cdn.jsdelivr.net/npm/mathjax@4.0.0-alpha.1/es5/tex-mml-chtml.js'
  document.head.appendChild(mathjaxJs);
}

MathJax = {
  svg: {
    mtextInheritFont: true
  },
  chtml: {
    mtextInheritFont: true
  },
  tex: {
    inlineMath: [['$', '$'], ['\\(', '\\)']],
    processEscapes: true,
    macros: {
      dblcol: "\\!\\rt{0.1}\\mathrel{\\raise.13ex{\\substack{\\small \\circ \\\\ \\small \\circ}}}",
      hc: "\\!\\rt{0.1}\\mathrel{\\raise.13ex{\\substack{\\small \\circ \\\\ \\small \\circ}}}",
      rr: "\\mathbb{R}",
      zz: "\\mathbb{Z}",
      nn: "\\mathbb{N}",
      ww: "\\mathbb{W}",
      qq: "\\mathbb{Q}",
      te: "\\text",
      dom: "\\text{dom}\\,",
      degree: "\\text{deg}\\,",
      f: "\\Rule{0.12em}{0.8pt}{-0.8pt}f",
      fsp: "\\hspace{0.06em}\\Rule{0.12em}{0.8pt}{-0.8pt}f",
      sp: "\\Rule{0.08em}{0.8pt}{-0.8pt}",
      ra: "\\rightarrow",
      back: "\\backslash",
      sqt: "{\\color{white} *\\!\\!\\!}",
      up: ["\\rule{0pt}{#1em}", 1],   // vspace doesn't seem to work / exist ?
      dn: ["\\Rule{0pt}{0em}{#1em}", 1],
      rt: ["\\hspace{#1em}", 1],
      hlfbk: "\\!\\hspace{0.1em}",
      fl: ["\\lfloor #1 \\rfloor", 1],
      cl: ["\\lceil #1 \\rceil", 1],
      FL: ["\\left\\lfloor #1 \\right\\rfloor", 1],
      CL: ["\\left\\lceil #1 \\right\\rceil", 1],
      implies: "\\Longrightarrow",
      psa: "{}\\!\\hspace{0.0691em}",
      psb: "{}\\!\\hspace{0.06901311249137em}",
      ncdot: "\\re\\cdot\\re",
      re: "\\!\\hspace{0.1em}",
      bk: "\\!\\hspace{0.1em}",
      gbk: "\\!\\hspace{0.15em}",
      fw: "\\hspace{0.1em}",
      hfbk: "\\!\\hspace{0.2em}",
      deg: "\\circ",
      km: "[\\text{km}]",
      ddx: "{d \\over dx}\\hspace{0.1em}",
      ddt: "{d \\over dt}\\hspace{0.1em}",
      ddu: "{d \\over du}\\hspace{0.1em}",
      ddz: "{d \\over dz}\\hspace{0.1em}",
      ov: ["\\overline{#1}", 1],
      floor: ["\\lfloor{#1}\\rfloor", 1],
      faketextelement: "{\\color{white}\\text{*}}\\!\\!\\!\\rt{0.1}"
    }
  },
  options: {
    skipHtmlTags: {'[+]': ['math-element']}
  },
  loader: {
    load: ['[tex]/color']
  },
  startup: {
    ready: () => {
      //
      //  Get some MathJax objects from the MathJax global
      //
      //  (Ideally, you would turn this into a custom component, and
      //  then these could be handled by normal imports, but this is
      //  just an example and so we use an expedient method of
      //  accessing these for now.)
      //
      const mathjax = MathJax._.mathjax.mathjax;
      const HTMLAdaptor = MathJax._.adaptors.HTMLAdaptor.HTMLAdaptor;
      const HTMLHandler = MathJax._.handlers.html.HTMLHandler.HTMLHandler;
      const AbstractHandler = MathJax._.core.Handler.AbstractHandler.prototype;
      const startup = MathJax.startup;

      //
      //  Extend HTMLAdaptor to handle shadowDOM as the document
      //
      class ShadowAdaptor extends HTMLAdaptor {
        create(kind, ns) {
          const document = (this.document.createElement ? this.document : this.window.document);
          return (ns ?
                  document.createElementNS(ns, kind) :
                  document.createElement(kind));
        }
        text(text) {
          const document = (this.document.createTextNode ? this.document : this.window.document);
          return document.createTextNode(text);
        }
        head(doc) {
          return doc.head || (doc.firstChild || {}).firstChild || doc;
        }
        body(doc) {
          return doc.body || (doc.firstChild || {}).lastChild || doc;
        }
        root(doc) {
          return doc.documentElement || doc.firstChild || doc;
        }
      }

      //
      //  Extend HTMLHandler to handle shadowDOM as document
      //
      class ShadowHandler extends HTMLHandler {
        create(document, options) {
          const adaptor = this.adaptor;
          if (typeof(document) === 'string') {
            document = adaptor.parse(document, 'text/html');
          } else if ((document instanceof adaptor.window.HTMLElement ||
                      document instanceof adaptor.window.DocumentFragment) &&
                     !(document instanceof window.ShadowRoot)) {
            let child = document;
            document = adaptor.parse('', 'text/html');
            adaptor.append(adaptor.body(document), child);
          }
          //
          //  We can't use super.create() here, since that doesn't
          //    handle shadowDOM correctly, so call HTMLHandler's parent class
          //    directly instead.
          //
          return AbstractHandler.create.call(this, document, options);
        }
      }

      //
      //  Register the new handler and adaptor
      //
      startup.registerConstructor('HTMLHandler', ShadowHandler);
      startup.registerConstructor('browserAdaptor', () => new ShadowAdaptor(window));

      //
      //  A service function that creates a new MathDocument from the
      //  shadow root with the configured input and output jax, and then
      //  renders the document.  The MathDocument is returned in case
      //  you need to rerender the shadowRoot later.
      //
      MathJax.typesetShadow = function (root) {
        const InputJax = startup.getInputJax();
        const OutputJax = startup.getOutputJax();
        const html = mathjax.document(root, {InputJax, OutputJax});
        html.render();
        return html;
      }

      //
      //  Now do the usual startup now that the extensions are in place
      //
      MathJax.startup.defaultReady();

      class MathText extends HTMLElement {
        connectedCallback() {
            const content_ =
              this.display
                ? '$$' + this.content + '$$'
                : '$' + this.content + '$' ;
            this.attachShadow({mode: "open"});
            this.shadowRoot.innerHTML =
                '<mjx-doc><mjx-head></mjx-head><mjx-body>' + content_ + '</mjx-body></mjx-doc>';
                 MathJax.typesetShadow(this.shadowRoot)
            if (this.delay) {
              setTimeout(() => MathJax.typesetShadow(this.shadowRoot), 1);
            }
        }
      }
      customElements.define('math-text', MathText)
    }
  }
};
