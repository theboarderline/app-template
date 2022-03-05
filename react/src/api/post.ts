import { postData } from './http';


export const signup = async (email: string, password: string, confirmPassword: string): Promise<void> => {
  const formData = new FormData();
  formData.append('email', email);
  formData.append('password1', password);
  formData.append('password2', confirmPassword);

  return postData('register/', formData)
    .then((res) => {
      return res;
    })
    .catch((error) => {
      console.log(error);
      return error;
    });
};


export const logout = async (): Promise<void> => {
  const formData = new FormData();
  return postData('auth/logout/', formData);
};


export const login = async (email: string, password: string): Promise<void> => {
  const formData = new FormData();
  formData.append('username', email);
  formData.append('password', password);

  return postData('auth/login/', formData)
    .then((res) => {
      return res;
    })
    .catch((error) => {
      console.log(error);
      return error;
    });
};


export const memberSignup = async (
  phone: string,
  address: string
): Promise<void> => {
  const formData = new FormData();
  formData.append('phone', phone);
  formData.append('address', address);

  return postData('members/', formData)
    .then((res) => {
      return res;
    })
    .catch((error) => {
      console.log(error);
    });
};


export const uploadProfile = async (file: File | undefined): Promise<void> => {
  const formData = new FormData();
  formData.append('filename', file || '');

  return postData('profiles/', formData)
    .then((res) => {
      if (res?.status !== 201) {
        console.log('POST PROFILE ERROR:', res);
      }
      return res;
    })
    .catch((error) => {
      console.log('UPLOAD POST ERROR:', error);
    });
};


export const uploadFile = async (file: File | undefined): Promise<void> => {
  const formData = new FormData();
  formData.append('filename', file || '');

  return postData('photos/', formData)
    .then((res) => {
      if (res?.status !== 201) {
        console.log('POST FILE ERROR:', res);
      }
      return res;
    })
    .catch((error) => {
      console.log('UPLOAD FILE ERROR:', error);
    });
};
