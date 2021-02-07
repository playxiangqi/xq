import axios from 'axios';
import applyCaseMiddleware from 'axios-case-converter';

export const apiClient = applyCaseMiddleware(axios.create());
