// https://github.com/rM-self-serve/webinterface-upload-button

async function wait4header() {
    for (let i=0; i<20; i++) {
        const hgroups = document.getElementsByClassName('header-group');
        if (hgroups.length > 1) {
            return hgroups; 
        }
        await new Promise(r => setTimeout(r, 100))
    }
    return null;
}

async function init() {
    var css = `.header-button-ovrd { 
        background-color: transparent;
    };`;
    var style = document.createElement('style');
    if (style.styleSheet) {
        style.styleSheet.cssText = css;
    } else {
        style.appendChild(document.createTextNode(css));
    }
    document.getElementsByTagName('head')[0].appendChild(style);
    
    const hgroups = await wait4header();
    const my_files_box = hgroups[0];
    my_files_box.style.flex = "10 1 auto";

    let btns_elm = hgroups[1];
    let hbtn_elm = btns_elm.firstChild;

    let upbtn_node = document.createElement("a");
    upbtn_node.role = "button";
    upbtn_node.id = "upbtn";
    upbtn_node.className = hbtn_elm.classList[0];
    upbtn_node.appendChild(hbtn_elm.firstChild.cloneNode(true));
    upbtn_node.classList.add("header-button-ovrd")
    upbtn_node.style.borderWidth = "0px 0px 0px 1px";

    let icon_elm = upbtn_node.firstChild.firstChild;
    icon_elm.style.transform = "rotate(180deg)";

    btns_elm.insertBefore(upbtn_node, hbtn_elm);

    upbtn_node.addEventListener("click", handleSubmit);
}

let global_is_uploading = false;

async function handleSubmit(_) {
    if (global_is_uploading) {
        return;
    }
    let input = document.createElement('input');
    input.type = 'file';
    input.multiple = true;
    input.accept = ".pdf,.epub"
    input.onchange = async _ => await input_auto_submit(input);
    input.click();
}

async function input_auto_submit(input) {
    global_is_uploading = true;
    let list_elm = document.getElementsByClassName('list')[0];
    let list_ref = list_elm.removeChild(list_elm.childNodes[1]);
    let loaderNode = document.createElement("div");
    loaderNode.className = "loader";
    let loader_ref = list_elm.appendChild(loaderNode);

    for (let value of input.files) {
        if (value.name === "") {
            break;
        };
        const extnsn = value.name.split('.').pop();
        if (extnsn != "pdf" && extnsn != "epub") {
            window.alert("Error: File must be of the type pdf or epub\n\n" + value.name);
            continue;
        };
        const formDataIN = new FormData();
        formDataIN.append("file", value);
        const fetchOptions = {
            method: "post",
            body: formDataIN,
        };
        let response;
        try {
            response = await fetch("/upload", fetchOptions);
        }
        catch (e) {
            window.alert("Error: " + e);
            continue;
        }
        if (response.status != '200' && response.status != '201') {
            let e_str = "Error uploading: " + value.name
                + "\n\n" + response.status + " " + response.statusText.toLowerCase();
            window.alert(e_str);
            continue;
        }

        const list_entry = create_list_entry(value.name);
        list_ref.insertBefore(list_entry, list_ref.firstChild);
    }

    global_is_uploading = false;
    list_elm.removeChild(loader_ref)
    list_elm.appendChild(list_ref)
}

function create_list_entry(file_name) {
    const outer_div = document.createElement('div');

    const abtn = document.createElement('a');
    abtn.role = "button";

    const drow = document.createElement('div');
    drow.classList.add("row");

    const drow_el_grp = document.createElement('div');
    drow_el_grp.classList.add("row-element-group");

    const drow_el_grp1 = document.createElement('div');
    drow_el_grp1.classList.add("row-element");
    drow_el_grp1.classList.add("row-icon");

    const icon = document.createElement('i');
    icon.classList.add("icon-rm_documents");

    const drow_el_grp2 = document.createElement('div');
    drow_el_grp2.classList.add("row-element");
    drow_el_grp2.classList.add("row-title");
    drow_el_grp2.textContent = file_name;

    const dtimestamp = document.createElement('div');
    dtimestamp.classList.add("row-element");
    dtimestamp.classList.add("row-timestamp");
    dtimestamp.textContent = "0 seconds ago";

    outer_div.appendChild(abtn);

    abtn.appendChild(drow);

    drow.appendChild(drow_el_grp);
    drow.appendChild(dtimestamp);

    drow_el_grp.appendChild(drow_el_grp1);
    drow_el_grp.appendChild(drow_el_grp2);

    drow_el_grp1.appendChild(icon);

    return outer_div;
}


init()
