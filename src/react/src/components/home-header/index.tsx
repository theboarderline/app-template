import * as React from 'react';

import './styles.scss';

const HomeHeader: React.FC = () => {
  return (
        <>
          <div className="jumbotron bg-cover text-white">
            <div className="container py-5 text-center">
              <h2 className="home-header-title display-4 font-weight-bold">Welcome to the Rambler Project</h2>
            </div>
          </div>
        </>
    );
};

export default HomeHeader;
