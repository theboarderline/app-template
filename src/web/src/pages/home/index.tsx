import * as React from 'react';
import { RouteComponentProps, withRouter } from 'react-router-dom';
import { Accordion, AccordionTab } from 'primereact/accordion';
import {Container} from '@material-ui/core';
import { Card } from 'primereact/card';

import './styles.scss';
import {Footer, HomeHeader} from "../../components";


const Home: React.FC<RouteComponentProps> = () => {
  return (
    <Container>
      <HomeHeader/>
        <Card>
          <div className='lg-home'>
          <Accordion multiple>
            <AccordionTab header="Goal"></AccordionTab>
            
            <AccordionTab header="Services"></AccordionTab>
            
            <AccordionTab header="Process"></AccordionTab>
          </Accordion>
          </div>
        </Card>
      <Footer/>
    </Container>
  )
};

export default withRouter(Home);


