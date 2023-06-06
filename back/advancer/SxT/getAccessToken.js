import * as dotenv from "dotenv";
dotenv.config();

// Initializing the Space and Time SDK for use.
import SpaceAndTimeSDK from "../../SxT-NodeJS-SDK/SpaceAndTimeSDK.js";
const initSDK = SpaceAndTimeSDK.init();

// Authenticate yourself using the Space and Time SDK.
let [tokenResponse, tokenError] = await initSDK.AuthenticateUser();

console.log({ tokenResponse, tokenError });
