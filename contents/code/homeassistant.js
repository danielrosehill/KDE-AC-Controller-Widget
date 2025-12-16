// Home Assistant API Handler
.pragma library

function callService(haUrl, token, domain, service, entityId, serviceData, callback) {
    var xhr = new XMLHttpRequest();
    var url = haUrl + "/api/services/" + domain + "/" + service;

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200 || xhr.status === 201) {
                callback(true, JSON.parse(xhr.responseText));
            } else {
                console.error("Service call failed:", xhr.status, xhr.responseText);
                callback(false, null);
            }
        }
    };

    xhr.open("POST", url);
    xhr.setRequestHeader("Authorization", "Bearer " + token);
    xhr.setRequestHeader("Content-Type", "application/json");

    var data = {
        entity_id: entityId
    };

    if (serviceData) {
        for (var key in serviceData) {
            data[key] = serviceData[key];
        }
    }

    xhr.send(JSON.stringify(data));
}

function getState(haUrl, token, entityId, callback) {
    var xhr = new XMLHttpRequest();
    var url = haUrl + "/api/states/" + entityId;

    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                var data = JSON.parse(xhr.responseText);
                callback(true, data);
            } else {
                console.error("Get state failed:", xhr.status, xhr.responseText);
                callback(false, null);
            }
        }
    };

    xhr.open("GET", url);
    xhr.setRequestHeader("Authorization", "Bearer " + token);
    xhr.send();
}

function setHvacMode(haUrl, token, entityId, mode, callback) {
    callService(haUrl, token, "climate", "set_hvac_mode", entityId,
                { hvac_mode: mode }, callback);
}

function setTemperature(haUrl, token, entityId, temperature, callback) {
    callService(haUrl, token, "climate", "set_temperature", entityId,
                { temperature: temperature }, callback);
}

function turnOn(haUrl, token, entityId, callback) {
    callService(haUrl, token, "climate", "turn_on", entityId, null, callback);
}

function turnOff(haUrl, token, entityId, callback) {
    callService(haUrl, token, "climate", "turn_off", entityId, null, callback);
}
