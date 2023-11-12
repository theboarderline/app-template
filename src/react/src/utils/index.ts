import dayjs from "dayjs";

export const check = (query?: string | number | null): boolean =>
  query !== null &&
  query !== undefined &&
  query !== -1 &&
  query !== '-1' &&
  query !== 'All' &&
  query !== 'undefined' &&
  query !== 'null' &&
  query !== '';

export const LIFECYCLE = check(window.LIFECYCLE)
  ? window.LIFECYCLE
  : 'local';

export const getCurrentUrl = (hostname: string, port?: number): string => {
  if (!port) port = 8000
  
  if (hostname === 'localhost') return `http://localhost:${port}`;
  
  return encodeURI(`https://${window.location.hostname}`);
};

export const API_URL = getCurrentUrl(window.location.hostname) + '/api'

export const APP_CODE = check(window.APP_CODE)
  ? window.APP_CODE
  : 'boatload';

export const STATIC_BUCKET = check(window.PUBLIC_BUCKET)
  ? window.PUBLIC_BUCKET
  : `dev-${APP_CODE}-v3-public-content`

export const GOOGLE_MAPS_KEY = check(window.GOOGLE_MAPS_KEY)
  ? window.GOOGLE_MAPS_KEY
  : 'AIzaSyBi8c_FjiOPkerecsw2u4hmqjuIhwNQJQM';

export const upperCaseFirst = (s: string) => {
  return s.charAt(0).toUpperCase() + s.slice(1);
}

export const getPlaceholder = (label: string) => {
  return upperCaseFirst(label)?.replace('-', ' ')
}

export const validateEmail = (emailStr: string) => {
  if (/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/.test(emailStr))
    return true
  
  return false
}

export const validatePhone = (phoneStr: string) => {
  if(/^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/.test(phoneStr))
    return true
  
  return false
}

// validate that a number is a 6 digit auth code
export const validateCode = (codeStr: string) => {
  if(/^\d{6}$/.test(codeStr))
    return true
  
  return false
}


export const formatDate = (date: string) => {
  if (!date) return
  return dayjs(date).format('LL')
}

export const formatEST = (time?: string) => {
  if (!time) return
  time = `01/01/1970 ${time}`
  const d = new Date(time).toLocaleString()
  console.log('time', d)
  return dayjs(d).format('LT')
}

const getTimeDiffStr = (num: number, str: string) => {
    let returnStr = str
    if (num !== 1)
      returnStr += 's'
    return `${num} ${returnStr} ago`
}

export const getTimeDiff = (created: string) => {
  
  const dateCreated = new Date(created)
  const today = new Date()
  const diff = today.getTime() - dateCreated.getTime();
  
  let msec = diff;
  const yy = Math.floor(msec / 1000 / 60 / 60 / 24 / 30 / 365.25);
  msec -= yy * 1000 * 60 * 60 * 24 * 30 * 365.25;
  const mo = Math.floor(msec / 1000 / 60 / 60 / 24 / 30);
  msec -= mo * 1000 * 60 * 60 * 24 * 30;
  const dd = Math.floor(msec / 1000 / 60 / 60 / 24);
  msec -= dd * 1000 * 60 * 60 * 24;
  const hh = Math.floor(msec / 1000 / 60 / 60);
  msec -= hh * 1000 * 60 * 60;
  const mm = Math.floor(msec / 1000 / 60);
  msec -= mm * 1000 * 60;
  const ss = Math.floor(msec / 1000);
  
  if (yy > 0) {
    return getTimeDiffStr(yy, 'year')
  }
  if (mo > 0) {
    return getTimeDiffStr(mo, 'month')
  }
  if (dd > 0) {
    return getTimeDiffStr(dd, 'day')
  }
  if (hh > 1) {
    return getTimeDiffStr(hh, 'hour')
  }
  if (mm > 1) {
    return getTimeDiffStr(mm, 'minute')
  }
  return getTimeDiffStr(ss, 'second')
  
}


export const getError = (data: any): string => {
  console.log('GETTING ERROR MSG:', data);

  if (data?.non_field_errors?.length) {
    return JSON.stringify(data.non_field_errors[0]);
  }
  if (data?.error) return data.error;
  if (data?.detail) return data.detail;
  if (data?.username?.length > 0) return data.username[0];
  if (data?.new_password2) return data.new_password2;
  if (data?.sport) return data.sport;
  if (data?.community) return data.community;

  if (data) return JSON.stringify(data);
  return data
};

export const fixURI = (url: string): string => {
  let ret = url;
  if (!url.includes('localhost')) ret = url.replace('http', 'https');
  return encodeURI(ret);
};


export const gcsBucket = `https://storage.googleapis.com/${STATIC_BUCKET}`;
