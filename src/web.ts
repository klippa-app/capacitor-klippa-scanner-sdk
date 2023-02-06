import { WebPlugin } from '@capacitor/core';

import { CameraConfig, CameraResult, KlippaScannerSDKPlugin } from '.';

export class KlippaScannerSDKPluginWeb
    extends WebPlugin
    implements KlippaScannerSDKPlugin {

    async getCameraResult(_: CameraConfig): Promise<CameraResult> {
        throw this.unimplemented('Not implemented on web.');
    }
}
