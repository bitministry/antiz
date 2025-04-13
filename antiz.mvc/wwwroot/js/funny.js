function addQueryToUrl(url, query) {
    return !query
        ? url
        : (url.includes("?")
            ? url + "&" + query
            : url + "?" + query);
}

function reloadAndExecute( scriptId ) {
    const oldScript = document.getElementById(scriptId);
    const scriptSrc = oldScript.src; 
    if (oldScript) {
        oldScript.remove();
    }

    const script = document.createElement('script');
    script.id = scriptId;
    script.src = scriptSrc + '?t=' + new Date().getTime();
    script.onload = () => console.log('Script loaded and executed!');
    script.onerror = () => console.error('Failed to load script:', scriptSrc);
    document.head.appendChild(script);
}

function forceExecuteRemote(src) {

    fetch(src +'?t=' + new Date().getTime())
        .then(response => response.text())
        .then(code => {
            eval(code); // Dangerous, but works for controlled scripts
            console.log(src+ ' executed!');
        })
        .catch(err => console.error('Error loading ' + src, err));


}