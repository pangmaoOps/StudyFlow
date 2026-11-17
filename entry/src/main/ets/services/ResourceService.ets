import { http } from '@kit.NetworkKit';

export interface StudyResource { id: number; title: string; body: string; }
export async function getResources(): Promise<StudyResource[]> {
  const client = http.createHttp();
  try {
    const response = await client.request('https://jsonplaceholder.typicode.com/posts?_limit=8', {
      method: http.RequestMethod.GET,
      connectTimeout: 10000,
      readTimeout: 10000,
      expectDataType: http.HttpDataType.STRING
    });
    if (response.responseCode < 200 || response.responseCode >= 300) throw new Error('HTTP ' + response.responseCode);
    return JSON.parse(response.result as string) as StudyResource[];
  } finally { client.destroy(); }
}
