import * as React from 'react';
import Loader from 'react-loader-spinner';
import 'react-loader-spinner/dist/loader/css/react-spinner-loader.css';
import {Dialog} from "primereact/dialog";

interface LoaderProps {
  loading: boolean
  dialog?: boolean
}

const LoaderComponent: React.FC<LoaderProps> = ({ loading, dialog }) => {
  
  const loader = (
    <Loader
      visible
      type="BallTriangle"
      color="#00BFFF"
      height={40}
      width={40}
    />
  )
  
  if (loading)
    return (
      <div id="loader">
        {dialog ? (
          <Dialog visible={loading} style={{ width: '450px' }} header="Fetching Data..." modal className="p-fluid" onHide={() => {}}>
            {loader}
          </Dialog>
        ) : loader}
      </div>
    );
  return null;
};

export default LoaderComponent;
