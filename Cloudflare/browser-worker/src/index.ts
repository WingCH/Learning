/**
 * Welcome to Cloudflare Workers! This is your first worker.
 *
 * - Run `npm run dev` in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run `npm run deploy` to publish your worker
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

import puppeteer, { BrowserWorker } from '@cloudflare/puppeteer';

interface Env {
	MYBROWSER: Fetcher;
	BROWSER_KV_DEMO: KVNamespace;
}

export default {
	async fetch(request: Request, env: Env): Promise<Response> {
		const { searchParams } = new URL(request.url);
		let url = searchParams.get('url');
		let img: ArrayBuffer | null;
		if (url) {
			url = new URL(url).toString(); // normalize
			img = await env.BROWSER_KV_DEMO.get(url, { type: 'arrayBuffer' });
			if (img === null) {
				// does not work in local mode, https://github.com/cloudflare/puppeteer/issues/24#issuecomment-1770532268
				const browser = await puppeteer.launch(env.MYBROWSER as unknown as BrowserWorker);
				const page = await browser.newPage();
				await page.goto(url);
				img = (await page.screenshot()) as Buffer;
				await env.BROWSER_KV_DEMO.put(url, img, {
					expirationTtl: 60 * 60 * 24
				});
				await browser.close();
			}
			return new Response(img, {
				headers: {
					'content-type': 'image/jpeg'
				}
			});
		} else {
			return new Response(
				'Please add an ?url=https://example.com/ parameter'
			);
		}
	}
};
