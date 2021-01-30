import 'phoenix_html';

import App from './App.svelte';

new App({
  target: document.body,
  props: {
    name: 'world',
  },
});
