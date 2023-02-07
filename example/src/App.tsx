import { IonApp, IonButton, setupIonicReact, useIonAlert } from '@ionic/react';

import { KlippaScannerSDK } from "@klippa/capacitor-klippa-scanner-sdk"
import { KlippaScannerConfig } from './klippa-config'



/* Core CSS required for Ionic components to work properly */
import '@ionic/react/css/core.css';

/* Basic CSS for apps built with Ionic */
import '@ionic/react/css/normalize.css';
import '@ionic/react/css/structure.css';
import '@ionic/react/css/typography.css';

/* Optional CSS utils that can be commented out */
import '@ionic/react/css/padding.css';
import '@ionic/react/css/float-elements.css';
import '@ionic/react/css/text-alignment.css';
import '@ionic/react/css/text-transformation.css';
import '@ionic/react/css/flex-utils.css';
import '@ionic/react/css/display.css';

/* Theme variables */
import './theme/variables.css';
import React from 'react';

setupIonicReact();

const App: React.FC = () => {
    const [present] = useIonAlert();
    return <IonApp>
        <IonButton onClick={
            () => {
                KlippaScannerSDK.getCameraResult(KlippaScannerConfig).then((result) => {
                    console.log(result);

                    console.log(result.images.length);
                    console.log(result.images);

                    present({
                        header: 'Alert',
                        message: `Took ${result.images.length} pictures`,
                        buttons: ['Ok'],
                    })
                })
            }}>
            Start scanner
        </IonButton>
    </IonApp>
};

export default App;
