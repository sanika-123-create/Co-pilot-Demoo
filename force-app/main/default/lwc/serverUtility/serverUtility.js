/* eslint-disable no-use-before-define */
import createLogRecord from "@salesforce/apex/LogFactory.createLogRecord";
import SharedUtil from "c/sharedUtility";

const serverCallHandler = (serverAction, params, childInstance) => {
	setLoader(childInstance, true);
	return new Promise((resolve) => {
		serverAction(params)
			.then((data) => {
				resolve(data);
				setLoader(childInstance, false);
			})
			.catch((error) => {
				// eslint-disable-next-line @salesforce/aura/ecma-intrinsics
				if (isErrorHandled(error) && childInstance && childInstance.processHandledErrors) {
					childInstance.processHandledErrors(getCustomException(error));
				} else {
					logError(error, serverAction);
				}
				setLoader(childInstance, false);
			})
			.finally(() => {
				//setLoader(childInstance, false);
			});
	});
};

const setLoader = (childInstance, val) => {
	// eslint-disable-next-line @salesforce/aura/ecma-intrinsics
	if (childInstance) {
		childInstance.isLoading = val;
	}
};

// eslint-disable-next-line no-unused-vars
const isErrorHandled = (error) => {
	return error?.body?.exceptionType === "CustomException" && error.body.message && CONSTANTS.handledErrors.includes(JSON.parse(error.body.message).message);
};

const getCustomException = (error) => {
	let exp = error?.body?.exceptionType === "CustomException" && error.body.message;
	return exp ? JSON.parse(exp) : null;
};

const logError = (error, serverAction) => {
	console.error("Error occurred: ", error);
	SharedUtil.showErrorToast(error);
	createLogRec(error, serverAction);
};

const createLogRec = (error, serverAction) => {
	// Log error by creating record
	const compName = serverAction?.adapter?.name ?? serverAction ?? "UI-LWC Exception";
	const errorStackTrace = error?.body?.stackTrace ?? "Server stack unavailable";
	const errorMessage = error?.body?.message ?? error?.message;
	const jsStack = error?.stack;
	// eslint-disable-next-line no-console, no-restricted-syntax
	let logDescription = "Message: " + errorMessage + "\n|| Stack: " + errorStackTrace + "\n|| URL: " + window.location.href + "\n|| JS Stack: " + jsStack;
	let params = {
		compName,
		title: "UI-LWC Exception",
		message: logDescription
	};
	createLogRecord(params);
};

const printLog = (logDesc, serverAction) => {
	const compName = serverAction?.adapter?.name ?? serverAction ?? "UI-LWC Exception";
	let params = {
		compName,
		title: "UI-LWC Exception",
		message: logDesc
	};
	createLogRecord(params);
};

export { serverCallHandler, isErrorHandled, createLogRec, logError, getCustomException, printLog };