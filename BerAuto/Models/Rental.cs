using System;
using System.Collections.Generic;

namespace BerAuto.Models;

public partial class Rental
{
    public enum RentalStatus
    {
        Requested = 0,
        Approved = 1,
        Active = 2,
        Closed = 3,
        Rejected = 4
    }

    public int Id { get; set; }

    public int UserId { get; set; }

    public int CarId { get; set; }

    public DateTime StartDate { get; set; }

    public DateTime EndDate { get; set; }

    public decimal? TotalCost { get; set; }

    public RentalStatus Status { get; set; } 

    public DateTime CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public virtual Car Car { get; set; } = null!;

    public virtual Invoice? Invoice { get; set; }

    public virtual User User { get; set; } = null!;
}
