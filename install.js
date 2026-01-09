import bashScript from './install.sh';
import batchScript from './install.bat';

// noinspection JSUnusedGlobalSymbols
export default {
    async fetch(request, env, ctx) {
        const url = URL(request.url);
        const path = url.pathname.toLowerCase();

        if (path === "windows") {
            return new Response('' + batchScript);
        } else if (path === "unix") {
            return new Response('' + bashScript);
        } else {
            return new Response('Invalid Install Type: ' + path.substring(1));
        }
    }
};