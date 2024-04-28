$(document).ready(function() {
  // 0 and 1 are for tax and tip payment components
  var indexForNextPaymentComponent = 2;
  $("#payment_component_fields_copy :input").attr("disabled", true);
  $("#tax-payment-component-container :input").attr("disabled", true);
  $("#tip-payment-component-container :input").attr("disabled", true);

  $('body').on('click', '#add-payment-component', function(event) {
    event.preventDefault();

    var paymentComponentId = "payment-component-" + indexForNextPaymentComponent;

    $(".payment-components-container").append(
      "<div class='payment-component mb-5' id='" + paymentComponentId + "'>" +
      $("#payment_component_fields_copy").html() +
      "</div>"
    );
    $("#" + paymentComponentId + " :input").attr("disabled", false);

    $("#" + paymentComponentId + " :input").each(function(){
      if ($(this).attr('name')) {
        var inputName = $(this).attr('name').replace(
          "[payment_components_attributes][0]", "[payment_components_attributes][" + indexForNextPaymentComponent + "]"
        );
        $(this).attr('name', inputName);
      }
    });

    indexForNextPaymentComponent += 1;
  });

  $('body').on('change', '.payment_component_amount', function(event) {
    generateTotals();
    syncPaymentComponent($(this).closest(".payment-component"));
  });

  $('body').on('change', '.user-select-checkbox', function(event) {
    var splitPaymentContainer = $(this).closest(".split-payment-container");

    splitPaymentContainer.find(".split-payment-user-id").attr("disabled", !$(this).is(":checked"));
    splitPaymentContainer.find(".split-payment-amount").attr("disabled", !$(this).is(":checked"));

    syncPaymentComponent($(this).closest(".payment-component"));
  });

  $('body').on('change', '.payment_component_split', function(event) {
    syncPaymentComponent($(this).closest(".payment-component"));
  });

  $('body').on('click', '#payment-component-remove-btn', function(event) {
    event.preventDefault();
    $(this).closest(".payment-component").remove();
  });

  $('body').on('click', '#add-tip-btn', function(event) {
    event.preventDefault();
    $('#tip-payment-component-container').removeClass('d-none');
    $(this).addClass('d-none');
    $('#remove-tip-btn').removeClass('d-none');
    $("#tip-payment-component-container :input").attr("disabled", false);
  });

  $('body').on('click', '#remove-tip-btn', function(event) {
    event.preventDefault();
    $('#tip-payment-component-container').addClass('d-none');
    $(this).addClass('d-none');
    $('#add-tip-btn').removeClass('d-none');
    $("#tip-payment-component-container :input").attr("disabled", true);
  });

  $('body').on('click', '#add-tax-btn', function(event) {
    event.preventDefault();
    $('#tax-payment-component-container').removeClass('d-none');
    $(this).addClass('d-none');
    $('#remove-tax-btn').removeClass('d-none');
    $("#tax-payment-component-container :input").attr("disabled", false);
  });

  $('body').on('click', '#remove-tax-btn', function(event) {
    event.preventDefault();
    $('#tax-payment-component-container').addClass('d-none');
    $(this).addClass('d-none');
    $('#add-tax-btn').removeClass('d-none');
    $("#tax-payment-component-container :input").attr("disabled", true);
  });

  $("#expenseModal").on("hidden.bs.modal", function () {
    $("#new_expense")[0].reset();
    $(".payment-components-container").html("");
    generateTotals();
  });
})

function generateTotals() {
  var subtotal = 0;
  var taxAmount = 0;
  var tipAmount = 0;

  $(".payment-components-container").find(".payment_component_amount").each(function() {
    var parsedValue = parseFloat($(this).val());

    if (!isNaN(parsedValue)) {
      subtotal += parsedValue;
    }
  })

  $("#tax-payment-component-container").find(".payment_component_amount").each(function() {
    var parsedValue = parseFloat($(this).val());

    if (!isNaN(parsedValue)) {
      taxAmount = parsedValue;
    }
  })

  $("#tip-payment-component-container").find(".payment_component_amount").each(function() {
    var parsedValue = parseFloat($(this).val());

    if (!isNaN(parsedValue)) {
      tipAmount = parsedValue;
    }
  })

  $("#expense-subtotal").html(subtotal);
  $("#expense-grandtotal").html(subtotal + taxAmount + tipAmount);
}

function syncPaymentComponent(paymentComponent) {
  if (paymentComponent.find(".payment_component_split").val() == "equal") {
    var parsedValue = parseFloat(paymentComponent.find(".payment_component_amount").val())

    var selectedUsersCount = paymentComponent.find(".split-payment-container").find(".user-select-checkbox:checked").length;
    var equalShareAmountAndOffset = calculateEqualShareAndOffset(selectedUsersCount, parsedValue)
    var offsetAdded = false;

    paymentComponent.find(".split-payment-container").each(function() {
      if ($(this).find(".user-select-checkbox:checked").length > 0) {
        if (offsetAdded) {
          $(this).find(".split-payment-amount").val(equalShareAmountAndOffset.equalShareAmount);
        } else {
          $(this).find(".split-payment-amount").val(
            (equalShareAmountAndOffset.equalShareAmount + equalShareAmountAndOffset.offset).toFixed(2)
          );
          offsetAdded = true;
        }
      } else {
        $(this).find(".split-payment-amount").val(0);
      }
      $(this).find(".split-payment-amount").prop("readonly", true);
    })
  } else {
    paymentComponent.find(".split-payment-container").find(".split-payment-amount").prop("readonly", false);
  }
}

function calculateEqualShareAndOffset(usersCount, amount) {
  if ((usersCount == 0) || isNaN(amount)) { return { equalShareAmount: 0, offset: 0 } }

  var equalShareAmount = Math.floor((amount/usersCount) * 100) / 100;
  var totalUsingEqualShare = parseFloat((equalShareAmount * usersCount).toFixed(2));
  var offset = parseFloat((amount - totalUsingEqualShare).toFixed(2));

  return { equalShareAmount: equalShareAmount, offset: offset }
}