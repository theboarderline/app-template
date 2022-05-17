export const check = (query?: string | number | null): boolean =>
  query !== null &&
  query !== undefined &&
  query !== -1 &&
  query !== '-1' &&
  query !== 'All' &&
  query !== 'undefined' &&
  query !== 'null' &&
  query !== '';

export const CURRENT_URL = check(window.API_URL)
  ? window.API_URL
  : 'http://localhost:8000/';

export const STATIC_BUCKET = check(window.STATIC_BUCKET)
  ? window.STATIC_BUCKET
  : 'dev-tp2-web-static';

export const getError = (data: any): string => {
  console.log('GETTING ERROR MSG:', data);

  if (data?.non_field_errors?.length) {
    return JSON.stringify(data.non_field_errors[0]);
  }
  if (data?.error) return data.error;
  if (data?.detail) return data.detail;
  if (data?.new_password2) return data.new_password2;
  if (data?.sport) return data.sport;
  if (data?.community) return data.community;

  return JSON.stringify(data);
};

export const fixURI = (url: string): string => {
  let ret = url;
  if (!url.includes('localhost')) ret = url.replace('http', 'https');
  return encodeURI(ret);
};

export const isJudge = (state: {
  isJudge: boolean;
  originalComm: string;
  community: string;
}): boolean => state.isJudge === true && state.originalComm === state.community;

export const gcsBucket = `https://storage.googleapis.com/${STATIC_BUCKET}`;
