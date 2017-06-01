import { ADD_WARD_RESULT, ADD_WARD_RESULTS, LOGOUT, CLEAR_DASHBOARD } from '../actions/index';

var initialState = [];

function wardResults(state = initialState, action) {
  switch (action.type) {
    case ADD_WARD_RESULT:
      return [
        ...state,
        {
          id: action.ward_result_params.id,
          rating: action.ward_result_params.rating,
          from: action.ward_result_params.from,
          msgId: action.ward_result_params.msg_id,
          msgText: action.ward_result_params.msg_text,
          wardAccountId: action.ward_result_params.ward_account_id,
          backend_id: action.ward_result_params.backend_id,
          timestamp: action.ward_result_params.timestamp
        }
      ];
    case ADD_WARD_RESULTS:
      return state.concat(
        action.ward_results.map(ward_result => {
          return {
            id: ward_result.id,
            rating: ward_result.rating,
            from: ward_result.from,
            msgId: ward_result.msg_id,
            msgText: ward_result.msg_text,
            wardAccountId: ward_result.ward_account_id,
            backend_id: ward_result.backend_id,
            timestamp: ward_result.timestamp
          };
        })
      );
    case LOGOUT:
      return initialState;
    case CLEAR_DASHBOARD:
      return initialState;
    default:
      return state;
  }
}

export default wardResults;