export default {
    async fetch(request, env, ctx) {
        // You can view your logs in the Observability dashboard
        console.info({ message: 'From GitHub' });
        return new Response('Hello World From GitHub!');
    }
};