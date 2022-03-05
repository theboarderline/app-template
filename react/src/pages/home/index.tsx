/* eslint-disable */
import * as React from 'react';
import AOS from 'aos';
import { RouteComponentProps, withRouter } from 'react-router-dom';
import { makeStyles } from '@material-ui/core/styles';

import GridContainer from '../../kit-components/Grid/GridContainer';
import GridItem from '../../kit-components/Grid/GridItem';

import SellerForm from '../../forms/member-form';
import {
  Grid,
  NeedToSell,
  WaysCard,
  SectionCards,
  Footer
} from '../../components';

// import styles from '../../assets/jss/material-kit-react/views/components';
import styles from '../../assets/jss/material-kit-react/views/componentsSections/tabsStyle'

import './styles.scss';
import { fadeUp } from '../../utils/animationsName';
import high from '../../assets/img/high.png';
import simplesystem from '../../assets/img/simplesystem.jpg';

const useStyles = makeStyles(styles);

const Home: React.FC<RouteComponentProps> = () => {

  React.useEffect(() => {
    AOS.init({
      duration: 2000
    })
  }, [])
  const classes = useStyles();
  const homeComponent = (
    <div className="cgs--home">
      <div className={`${classes.container} cgs--home-header`}>
        <div className="cgs--home-header-heading">
          Welcome to your first prototype!
        </div>
      </div>
      <div>
        <div>
          <div id='nav-tabs'>
            <GridContainer  >
              <GridItem xs={12} sm={12} md={12}>
                <GridItem xs={12} sm={12} md={12}>
                  <SellerForm />
                </GridItem>
                <div className={`${classes.section} section-tab-header`}>
                  <div className={classes.container}>
                    <GridContainer>
                      <GridItem xs={12}>
                        <div className="nav-tabs-desc">
                          Put some text here
                        </div>
                        <div className="nav-tabs-desc">
                          And here
                        </div>
                        <div className="nav-tabs-desc">
                          And maybe even here
                        </div>
                      </GridItem>
                      <GridItem className="section-card-grid-container" xs={12} sm={12} md={6} lg={4}>
                        <SectionCards
                          dataAos={fadeUp}
                          heading="1. Step One"
                          className={'section-card-1'}
                          desc="This is step 1"
                        />
                      </GridItem>
                      <GridItem className="section-card-grid-container" xs={12} sm={12} md={6} lg={4}>
                        <SectionCards
                          dataAos={fadeUp}
                          heading="2. Step Two"
                          className={'section-card-2'}
                          desc="This is step two"
                        />
                      </GridItem>

                      <GridItem className="section-card-grid-container" xs={12} sm={12} md={6} lg={4}>
                        <SectionCards
                          dataAos={fadeUp}
                          heading="3. Step Three"
                          className={'section-card-3'}
                          desc="Can you guess what this is?"
                        />
                      </GridItem>

                      <NeedToSell />

                      <GridItem lg={4}  >
                        <WaysCard image={high} desc="Card description 1" heading="Card heading 1" />
                      </GridItem>
                      <GridItem lg={4}  >
                        <WaysCard image={simplesystem} desc="Card description 2" heading="Card heading 2" />
                      </GridItem>
                      <GridItem lg={4}  >
                        <WaysCard image={simplesystem} desc="Card description 3" heading="Card heading 3" />
                      </GridItem>
                    </GridContainer>
                  </div>
                </div>

              </GridItem>

            </GridContainer>
          </div>
        </div>
      </div>

      <Footer />
    </div>
  );
  return (
    <Grid
      items={[
        {
          id: 'cgs--login',
          cols: { xs: 12, sm: 12, md: 12, lg: 12 },
          content: homeComponent,
          rows: 2
        }
      ]}
    />
  );
};

export default withRouter(Home);
