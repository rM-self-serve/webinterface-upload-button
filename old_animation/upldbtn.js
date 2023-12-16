document.getElementById('webint-upldbtn').innerHTML = `
    <div class="form_wrap">
        <form class="my_form" action="/upload" method="post" enctype="multipart/form-data">
            <input class="browbtn" name="file" type="file" multiple />
            <button class="upldbtn" id="upldbtn">Upload</button>
        </form>
    </div>
    <div class="spin_wrap">
        <div id="spinner" class="spinner "></div>
    </div>`

const form = document.querySelector('form');
form.addEventListener('submit', handleSubmit, false);

const loadButton = document.getElementById('upldbtn');

async function handleSubmit(event) {
    event.preventDefault()
    const form = event.currentTarget;
    const url = new URL(form.action);
    const formData = new FormData(form);
    const spinwrap = document.getElementById('spinner');
    const inital_state = spinwrap.cloneNode(true);
    spinwrap.classList.add("spin_action");
    spinwrap.style.borderColor = "transparent black";
    loadButton.disabled = true;

    for (let [_, value] of formData) {
        if (value.name === "") {
            spinwrap.style.borderColor = "transparent";
            loadButton.disabled = false;
            return;
        };
        console.log(value);
        const formDataIN = new FormData();
        formDataIN.append("file", value);
        const fetchOptions = {
            method: form.method,
            body: formDataIN,
        };
        let response;
        try {
            response = await fetch(url, fetchOptions);
        }
        catch (e) {
            window.alert("Error: " + e);
            continue;
        }
        if (response.status != '200' && response.status != '201') {
            let e_str = "Error uploading: " + value.name
                + "\n\n" + response.status + " " + response.statusText.toLowerCase();
            window.alert(e_str);
        }
    }

    loadButton.disabled = false;
    form.reset();

    spinwrap.classList.remove("spin_action");
    spinwrap.style.borderColor = "#7BC342";
    spinwrap.classList.add("fadei_action");
    await new Promise(r => setTimeout(r, 500));
    spinwrap.classList.remove("fadei_action");
    spinwrap.style.borderRadius = "50%";
    spinwrap.classList.add("spin_action_fast");
    await new Promise(r => setTimeout(r, 1000));
    spinwrap.classList.remove("spin_action_fast");
    spinwrap.classList.add("fadeo_action");
    await new Promise(r => setTimeout(r, 1000));
    spinwrap.style.opacity = 0;
    spinwrap.style.borderColor = "transparent";

    spinwrap.parentNode.replaceChild(inital_state, spinwrap);
}