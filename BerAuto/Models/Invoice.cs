using System;
using System.Collections.Generic;

namespace BerAuto.Models;

public partial class Invoice
{
    public int Id { get; set; }

    public int RentalId { get; set; }

    public DateTime IssueDate { get; set; }

    public decimal Amount { get; set; }

    public bool IsPaid { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual Rental Rental { get; set; } = null!;
}
