'use strict'



function ajax(url, returnType) {
    return new Promise(function (resolve, reject) {
        let request = new XMLHttpRequest();
        request.responseType = returnType;
        request.onreadystatechange = function () {
            if (request.readyState === XMLHttpRequest.DONE) {
                if (request.status === 200) {
                    resolve(request.response);
                }
                else {
                    reject(Error(request.status));
                    console.error('AJAX request to', url, 'failed. Got status', request.status);
                }
            }
        };
        request.onerror = function () {
            reject(Error("Network Error"));
            console.warn('AJAX request to', url, 'failed due to network error.');
        };
        request.open('GET', url);
        request.send();
    });
}

const lyrica = new Lyrica({
    el: "#lyrica-wrap",
    offsetTop: 50
});

const audio = $('audio');
audio.on('timeupdate', function () {
    lyrica.update(audio[0].currentTime);
});


let lyric_path = $('#lyrica-wrap')[0].getAttribute('value');

Promise.all([
    ajax(lyric_path, 'text')
]).then(function (res) {
    lyrica.load(res[0]);
});
