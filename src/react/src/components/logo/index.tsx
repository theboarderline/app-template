import * as React from 'react';
import { Image } from 'primereact/image';

import {gcsBucket} from "../../utils";

const Logo: React.FC = () => {
  return (
    <Image height={'70'} width={'80'} className="display-4 p-image" src={`${gcsBucket}/favicon.ico`}/>
  );
};

export default Logo;
