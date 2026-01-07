document.addEventListener("DOMContentLoaded", () => {
  const addBtn = document.getElementById("add-product");
  const productsDiv = document.getElementById("products");
  const template = document.getElementById("product-template");

  if (!addBtn) return;

  addBtn.addEventListener("click", () => {
    const time = new Date().getTime();
    const content = template.innerHTML.replace(/NEW_RECORD/g, time);
    productsDiv.insertAdjacentHTML("beforeend", content);
  });

  productsDiv.addEventListener("click", (e) => {
    if (e.target.classList.contains("remove-product")) {
      e.target.closest(".product-row").remove();
    }
  });
});
