/* eslint-env node */

/*
 * This file runs in a Node context (it's NOT transpiled by Babel), so use only
 * the ES6 features that are supported by your Node version. https://node.green/
 */

// Configuration for your app
// https://v2.quasar.dev/quasar-cli-webpack/quasar-config-js

const ESLintPlugin = require("eslint-webpack-plugin");
const fs = require("fs");
const path = require("path");

const { configure } = require("quasar/wrappers");

module.exports = configure(function (ctx) {
  return {
    supportTS: false,

    boot: ["axios"],

    css: ["app.scss"],

    extras: [
      "material-icons",
      "mdi-v6",
      "ionicons-v4",
      "eva-icons",
      "fontawesome-v6",
      "themify",
      "line-awesome",
      "bootstrap-icons",
      "roboto-font",
      "material-icons",
    ],

    build: {
      vueRouterMode: "hash", // available values: 'hash', 'history'
      chainWebpack(chain) {
        chain
          .plugin("eslint-webpack-plugin")
          .use(ESLintPlugin, [{ extensions: ["js", "vue"] }]);
      },
    },

    devServer: {
      server: {
        type: "https",
        options: {
          key: fs.readFileSync(path.resolve(__dirname, "certs/localhost.key")),
          cert: fs.readFileSync(path.resolve(__dirname, "certs/localhost.crt")),
        },
      },
      port: 8081,
      open: true,
    },

    framework: {
      config: {},
      plugins: ["Notify"],
    },

    animations: ["zoomIn", "zoomOut"],

    ssr: {
      pwa: false,
      prodPort: 3000,
      maxAge: 1000 * 60 * 60 * 24 * 30,
      chainWebpackWebserver(chain) {
        chain
          .plugin("eslint-webpack-plugin")
          .use(ESLintPlugin, [{ extensions: ["js"] }]);
      },
      middlewares: [
        ctx.prod ? "compression" : "",
        "render", // keep this as last one
      ],
    },

    pwa: {
      workboxPluginMode: "GenerateSW",
      workboxOptions: {},
      chainWebpackCustomSW(chain) {
        chain
          .plugin("eslint-webpack-plugin")
          .use(ESLintPlugin, [{ extensions: ["js"] }]);
      },
      manifest: {
        name: `LeadTo`,
        short_name: `LeadTo`,
        description: `Pagina Principal de LeadTo`,
        display: "standalone",
        orientation: "portrait",
        background_color: "#ffffff",
        theme_color: "#027be3",
        icons: [
          {
            src: "icons/icon-128x128.png",
            sizes: "128x128",
            type: "image/png",
          },
          {
            src: "icons/icon-192x192.png",
            sizes: "192x192",
            type: "image/png",
          },
          {
            src: "icons/icon-256x256.png",
            sizes: "256x256",
            type: "image/png",
          },
          {
            src: "icons/icon-384x384.png",
            sizes: "384x384",
            type: "image/png",
          },
          {
            src: "icons/icon-512x512.png",
            sizes: "512x512",
            type: "image/png",
          },
        ],
      },
    },

    cordova: {},

    capacitor: {
      hideSplashscreen: true,
    },

    electron: {
      bundler: "packager",
      packager: {},
      builder: {
        appId: "leadto",
      },
      chainWebpackMain(chain) {
        chain
          .plugin("eslint-webpack-plugin")
          .use(ESLintPlugin, [{ extensions: ["js"] }]);
      },
      chainWebpackPreload(chain) {
        chain
          .plugin("eslint-webpack-plugin")
          .use(ESLintPlugin, [{ extensions: ["js"] }]);
      },
    },
  };
});
