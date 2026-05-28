/* eslint-disable no-use-before-define */
import Toast from "lightning/toast";

const showErrorToast = (error) => {
	let message = error?.body?.message ?? error?.message ?? error ?? "Some error occurred!";
	let isLoggedOut = message?.includes?.("You do not have access to");
	message = isLoggedOut ? "Insufficient access or you might be logged out. Please click {loginUrl} to login." : message;
	let messageLinks;
	if (isLoggedOut) {
		messageLinks = {
			loginUrl: {
				url: getCommunityLoginUrl(),
				label: "here"
			}
		};
	}

	Toast.show(
		{
			label: error?.statusText ?? "Error",
			message: message,
			messageLinks,
			mode: "sticky",
			variant: "error"
		},
		this
	);
};

const getCommunityLoginUrl = () => {
	// this is specific to community
	// change this implementation based on the place where the component is loaded
	let path = window.location.pathname;
	let communityName = path?.split("/")?.[1];
	if (window.location.search) {
		path += window.location.search;
	}

	path = path && encodeURIComponent(path);
	return "/" + (communityName ? communityName : "") + "/s/login/" + (path ? "?startURL=" + path : "");
};

// this is just an example of how to use a shared variable with singleton pattern
let privateVariable = "default";

const getPrivateVariableValue = () => {
	return privateVariable;
};

const setPrivateVariableValue = (val) => {
	privateVariable = val;
}



export { showErrorToast, getCommunityLoginUrl, getPrivateVariableValue, setPrivateVariableValue };